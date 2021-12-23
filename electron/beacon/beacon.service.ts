import { Injectable } from '@angular/core';
import { ElectronService } from '../electron/electron.service';

@Injectable({
  providedIn: 'root'
})
export class BeaconService {

  constructor(
    private electron: ElectronService
  ) { }

  initBeacon() {
    console.log('starting scan');
    // this.electron.beaconScanner();
  }






}
