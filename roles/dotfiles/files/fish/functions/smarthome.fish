function smarthome -d "Control smarthome devices"
    set -l usage "Usage: smarthome <1-4> <on|off> | smarthome status"

    if not set -q SMARTHOME_HOST; or test -z "$SMARTHOME_HOST"
        echo "error: SMARTHOME_HOST is not set" >&2
        return 1
    end
    if not set -q SMARTHOME_USER; or test -z "$SMARTHOME_USER"
        echo "error: SMARTHOME_USER is not set" >&2
        return 1
    end
    if not set -q SMARTHOME_PASS; or test -z "$SMARTHOME_PASS"
        echo "error: SMARTHOME_PASS is not set" >&2
        return 1
    end

    set -l curl_opts -s --connect-timeout 5 --max-time 10

    if test (count $argv) -eq 1; and test "$argv[1]" = status
        set -l cookie_file (mktemp)
        curl $curl_opts -c $cookie_file "http://$SMARTHOME_HOST/login.csp" >/dev/null
        or begin
            echo "error: cannot reach $SMARTHOME_HOST" >&2
            rm -f $cookie_file
            return 1
        end
        set -l login_result (curl $curl_opts -c $cookie_file -b $cookie_file \
            "http://$SMARTHOME_HOST/login_auth.csp" \
            -d "auth_user=$SMARTHOME_USER&auth_passwd=$SMARTHOME_PASS")
        set -l curl_status $status
        if test $curl_status -ne 0
            echo "error: login request failed (curl exit $curl_status)" >&2
            rm -f $cookie_file
            return 1
        end
        if test -z "$login_result"
            echo "error: empty response from device" >&2
            rm -f $cookie_file
            return 1
        end
        if not string match -q '*"Status":1*' "$login_result"
            echo "error: login failed - $login_result" >&2
            rm -f $cookie_file
            return 1
        end
        set -l json (curl $curl_opts -b $cookie_file "http://$SMARTHOME_HOST/dev_status.csp")
        curl $curl_opts -b $cookie_file "http://$SMARTHOME_HOST/logout.csp" >/dev/null
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

    set -l cookie_file (mktemp)
    curl $curl_opts -c $cookie_file "http://$SMARTHOME_HOST/login.csp" >/dev/null
    or begin
        echo "error: cannot reach $SMARTHOME_HOST" >&2
        rm -f $cookie_file
        return 1
    end
    set -l login_result (curl $curl_opts -c $cookie_file -b $cookie_file \
        "http://$SMARTHOME_HOST/login_auth.csp" \
        -d "auth_user=$SMARTHOME_USER&auth_passwd=$SMARTHOME_PASS")
    set -l curl_status $status
    if test $curl_status -ne 0
        echo "error: login request failed (curl exit $curl_status)" >&2
        rm -f $cookie_file
        return 1
    end
    if test -z "$login_result"
        echo "error: empty response from device" >&2
        rm -f $cookie_file
        return 1
    end
    if not string match -q '*"Status":1*' "$login_result"
        echo "error: login failed - $login_result" >&2
        rm -f $cookie_file
        return 1
    end

    # field 7 in Netscape cookie format is the value; $NF returns the name when value is empty
    set -l fsession (grep fsession $cookie_file | awk '{print $7}')
    if test -z "$fsession"
        echo "error: no session token" >&2
        curl $curl_opts -b $cookie_file "http://$SMARTHOME_HOST/logout.csp" >/dev/null
        rm -f $cookie_file
        return 1
    end

    set -l payload '{"OutCtrl":[{"Id":['$id'], "Ckind":'$ckind', "Src":0, "Session":"'$fsession'"}]}'
    set -l response (curl $curl_opts -b $cookie_file -X POST "http://$SMARTHOME_HOST/dev_ctrl.csp" \
        -d "dev_ctrl=$payload")

    curl $curl_opts -b $cookie_file "http://$SMARTHOME_HOST/logout.csp" >/dev/null
    rm -f $cookie_file

    if string match -q '*"Ret":0*' "$response"
        echo " $id: $action"
    else
        echo "error: command failed - $response" >&2
        return 1
    end
end
