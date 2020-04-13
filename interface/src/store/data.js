import { Subject, of } from 'rxjs';
import { fromFetch } from 'rxjs/fetch';
import { switchMap, catchError } from 'rxjs/operators';
import { webSocket } from 'rxjs/webSocket';

const ws = webSocket('wss://poc-poc.weepee.cloud/socket');
const subject = new Subject();
const initialData = fromFetch('https://poc-poc.weepee.cloud/receive/state').pipe(
  switchMap(response => {
    if (response.ok) {
      return response.json();
    } else {
      return of({ error: true, message: `Error ${response.status}` });
    }
  }),
  catchError(err => {
    console.error(err);
    return of({ error: true, message: err.message });
  }),
);

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
        state = {
          ...state,
          switches: data,
        };
        subject.next(state);
      },
    });
  },
  subscribeWs: () => {
    ws.subscribe(data => {
      let newState = {};
      newState.switches = { ...state.switches, ...data.receive };
      state = {
        ...state,
        ...newState,
      };
      console.log(state);
      subject.next(state);
    });
  },
  toggleSwitch: switchname => {
    const status = state.switches[switchname] === 'on' ? 'off' : 'on';
    fetch('https://poc-poc.weepee.cloud/receive/' + switchname + '/' + status);
  },
  initialState,
};

export default dataStore;
