import { Subject } from 'rxjs';
import { fromFetch } from 'rxjs/fetch';
import { webSocket } from 'rxjs/webSocket';

const ws = webSocket('wss://172.16.30.48:3000/socket');
const subject = new Subject();
const initialData = fromFetch('http://172.16.30.48:3000/receive/state');

const initialState = {
  switches: {},
};

let state = initialState;

const dataStore = {
  init: () => subject.next(state),
  subscribe: setState => {
    subject.subscribe(setState);
  },
  subscribeInitialData: () => {
    initialData.subscribe({
      next: data => {
        console.log(data);
        state.switches = data;
      },
    });
  },
  subscribeWs: () =>
    ws.subscribe(data => {
      state.switches = data;
    }),
  initialState,
};

export default dataStore;
