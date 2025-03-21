### 10.0.0

- Flutter Sound v10.0 ([taudio](https://taudio.canardoux.xyz/)). Actually just a port of Flutter Sound v9.x (Please pay attention to the GPL License).
- fix 404 errors int the doc, because the API ref. was moved ([#1173](https://github.com/Canardoux/flutter_sound/issues/1173))
- Android : Use  MediaPlayer's asynchronous prepareAsync() instead of synchronous prepare(), to avoid ANRs when there is no network connection when trying to play from a remote URL. Many thanks to [Eric](https://github.com/ericbomgardner) for his [PR](https://github.com/Canardoux/flutter_sound_core/pull/13).
- Android : Fix a bug when startPlayer() fires an Exception [(#1174)](https://github.com/Canardoux/flutter_sound/issues/1174)
- Add a very simple guide on how to upgrade 9.x to 10.0

## 0.17.19

- A port of Flutter Sound 9.26.0
