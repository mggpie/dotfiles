function smarthome -d "Control smarthome devices"
    set -l usage "Usage: smarthome <1-4> <on|off> | smarthome status"

    if test (count $argv) -eq 1; and test "$argv[1]" = status
        set -l cookie_file (mktemp)
        # GET login page first - device requires an initial fsession cookie before auth
        curl -s -c $cookie_file "http://$SMARTHOME_HOST/login.csp" >/dev/null
        curl -s -c $cookie_file -b $cookie_file -X POST "http://$SMARTHOME_HOST/login_auth.csp" \
            -d "auth_user=$SMARTHOME_USER&auth_passwd=$SMARTHOME_PASS" >/dev/null
        set -l json (curl -s -b $cookie_file "http://$SMARTHOME_HOST/dev_status.csp")
        # release server-side session so we don't hit the concurrent session limit
        curl -s -b $cookie_file "http://$SMARTHOME_HOST/logout.csp" >/dev/null
        rm -f $cookie_file

        if test -z "$json"
            echo "error: no response" >&2
            return 1
        end

        echo $json | python3 -c "
import sys, json
d = json.load(sys.stdin)
for o in d['OutSwitch']:
    s = 'ON' if o['OutStat'] == 1 else 'OFF'
    print(f'    {o[\"Id\"]}: {s}')
"
        return 0
    end

    if test (count $argv) -ne 2
        echo $usage >&2
        return 1
    end

    set -l id $argv[1]
    set -l action $argv[2]

    if not string match -qr '^[1-4]$' $id
        echo "error: id must be 1-4" >&2
        return 1
    end

    set -l ckind
    switch $action
        case on
            set ckind 1
        case off
            set ckind 2
        case '*'
            echo "error: action must be on or off" >&2
            return 1
    end

    # GET login page first - device requires an initial fsession cookie before auth
    set -l cookie_file (mktemp)
    curl -s -c $cookie_file "http://$SMARTHOME_HOST/login.csp" >/dev/null
    curl -s -c $cookie_file -b $cookie_file -X POST "http://$SMARTHOME_HOST/login_auth.csp" \
        -d "auth_user=$SMARTHOME_USER&auth_passwd=$SMARTHOME_PASS" >/dev/null

    set -l fsession (grep fsession $cookie_file | awk '{print $NF}')
    if test -z "$fsession"
        echo "error: login failed" >&2
        rm -f $cookie_file
        return 1
    end

    set -l payload '{"OutCtrl":[{"Id":['$id'], "Ckind":'$ckind', "Src":0, "Session":"'$fsession'"}]}'
    set -l response (curl -s -b $cookie_file -X POST "http://$SMARTHOME_HOST/dev_ctrl.csp" \
        -d "dev_ctrl=$payload")

    # release server-side session so we don't hit the concurrent session limit
    curl -s -b $cookie_file "http://$SMARTHOME_HOST/logout.csp" >/dev/null
    rm -f $cookie_file

    if string match -q '*"Ret":0*' "$response"
        echo " $id: $action"
    else
        echo "error: command failed - $response" >&2
        return 1
    end
end
