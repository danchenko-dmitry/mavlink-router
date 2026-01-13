python3 -m pip install --user pymavlink
python3 - <<'PY'
from pymavlink import mavutil
import time
m = mavutil.mavlink_connection('tcp:172.16.139.178:5760', source_system=255, source_component=190)
for i in range(1000):
    m.mav.heartbeat_send(
        mavutil.mavlink.MAV_TYPE_GCS,
        mavutil.mavlink.MAV_AUTOPILOT_INVALID,
        0, 0, 0
    )
    time.sleep(1)
print("sent")
PY

