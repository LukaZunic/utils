import { Injectable } from '@angular/core';
import { Network } from '../../../shared/interfaces/network.interface';
import { ElectronService } from '../electron/electron.service';

@Injectable({
    providedIn: 'root'
})
export class WiFiService {

    constructor(private electron: ElectronService) {
        this.electron.nodeWifi.init();
    }

    scan(): Promise<Network[]> {
        return new Promise((resolve, reject) => {
            try {
                // const networkInterface = this.electron.childProcess.execSync('netsh wlan show networks').toString().split('\n').filter(item => !!item.trim())[0].replace(/Interface\s+name\s*:\s/gi, '').trim();

                const path = ((item) => item.endsWith('app') ? item : item + '/app')(this.electron.remote.app.getAppPath());
                this.electron.childProcess.execSync('START /WAIT /min ' + this.electron.path.join(path, './utils/WlanScan.exe').toString());

                this.electron.nodeWifi.scan((error, networks: Network[]) => {
                    if (error) {
                        console.log(error);
                        return reject(error);
                    }

                    resolve(networks);
                });
            } catch (error) {
                console.log(error);
                reject(error);
            }
        });
    }

    getCurrentConnection() {
        return new Promise((resolve, reject) => {
            this.electron.nodeWifi.getCurrentConnections((error, connections) => {
                if (error) {
                    console.log(error);
                    return reject(error);
                }
                console.log({connections});

                if (connections && connections.length) {
                    return resolve(connections[0]);
                }

                resolve(null);
            })
        });
    }
}
