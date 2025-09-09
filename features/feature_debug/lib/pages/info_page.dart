import 'package:core_utils/info_util.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> appInfo = InfoUtil.appInfo.data;

    Map<String, dynamic> deviceInfo = InfoUtil.deviceInfo.data;

    return Scaffold(
      appBar: AppBar(title: Text('信息页')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Column(
              children: [
                Text('App信息', style: TextStyle(fontWeight: FontWeight.w600)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: appInfo.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(appInfo.entries.elementAt(index).key),
                        subtitle: Text(
                          '${appInfo.entries.elementAt(index).value}',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              children: [
                Text('设备信息', style: TextStyle(fontWeight: FontWeight.w600)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: deviceInfo.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(deviceInfo.entries.elementAt(index).key),
                        subtitle: Text(
                          '${deviceInfo.entries.elementAt(index).value}',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
