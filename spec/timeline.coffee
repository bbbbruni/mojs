Timeline = window.mojs.Timeline
easing   = window.mojs.easing
    
describe 'Timeline ->', ->
  describe 'init ->', ->
    it 'calc totalDuration and totalTime', ->
      t = new Timeline duration: 1000, delay: 100
      expect(t.props.totalDuration).toBe  1000
      expect(t.props.totalTime).toBe      1100
      t = new Timeline duration: 1000, delay: 100, repeat: 5
      expect(t.props.totalDuration).toBe  6500
      expect(t.props.totalTime).toBe      6600
  describe 'defaults ->', ->
    it 'should have vars', ->
      t = new Timeline
      expect(t.props) .toBeDefined()
      expect(t.h)     .toBeDefined()
      expect(t.progress).toBe 0
    it 'should have defaults', ->
      t = new Timeline
      expect(t.defaults.duration).toBe 600
      expect(t.defaults.delay).toBe    0
      expect(t.defaults.yoyo).toBe     false
    it 'should extend defaults to options', ->
      t = new Timeline
        duration: 1000
      expect(t.o.duration).toBe 1000
      expect(t.o.delay).toBe    0
  describe 'start ->', ->
    it 'should calculate start time', ->
      t = new Timeline(duration: 1000, delay: 500).start()
      now = Date.now() + 500
      expect(t.props.startTime).not.toBeGreaterThan now
      expect(t.props.startTime).toBeGreaterThan     now-50
    it 'should recieve the start time', ->
      t = new Timeline(duration: 1000).start 1
      expect(t.props.startTime).toBe 1
    it 'should calculate end time', ->
      t = new Timeline(duration: 1000, delay: 500).start()
      expect(t.props.endTime).toBe t.props.startTime + 1000
    it 'should calculate end time if repeat', ->
      t = new Timeline(duration: 1000, delay: 500, repeat: 2).start()
      expect(t.props.endTime).toBe t.props.startTime+(3*(1000+500))-500
    it 'should restart flags', ->
      t = new Timeline(duration: 20, repeat: 2).start()
      t.update t.props.startTime + 10
      t.update t.props.startTime + 60
      expect(t.isCompleted).toBe true
      expect(t.isStarted)  .toBe true
      t.start()
      expect(t.isCompleted).toBe false
      expect(t.isStarted)  .toBe false
  describe 'update time ->', ->
    it 'should update progress', ->
      t = new Timeline(duration: 1000, delay: 500)
      t.start()
      time = t.props.startTime + 200
      t.update time
      expect(t.progress).toBe .2
    it 'should update progress with repeat', ->
      t = new Timeline(duration: 1000, delay: 200, repeat: 2)
      t.start()
      t.update t.props.startTime + 1400
      expect(t.progress).toBe .2
      t.update t.props.startTime + 2700
      expect(t.progress).toBe .3
      t.update t.props.startTime + 3400
      expect(t.progress).toBe 1
    it 'should update progress to 0 if in delay gap', ->
      t = new Timeline(duration: 1000, delay: 200, repeat: 2)
      t.start()
      t.update t.props.startTime + 1100
      expect(t.progress).toBe 0
    it 'should update progress to 1 on the end', ->
      t = new Timeline(duration: 1000, delay: 200, repeat: 2)
      t.start()
      t.update t.props.startTime + 1000
      expect(t.progress).toBe 1
    it 'should not call update method if timeline isnt active -', ->
      t = new Timeline(duration: 1000, onUpdate:->)
      spyOn t, 'onUpdate'
      t.start()
      t.update(Date.now() - 500)
      expect(t.onUpdate).not.toHaveBeenCalled()
    it 'should not call update method if timeline isnt active +', ->
      cnt = 0
      t = new Timeline(duration: 1000, onUpdate:-> cnt++ )
      t.start(); t.update(Date.now() + 1500)
      expect(cnt).toBe 1
    it 'should set Timeline to the end if Timeline ended', ->
      t = new Timeline(duration: 1000, delay: 500)
      t.start()
      t.update t.props.startTime + 1200
      expect(t.progress).toBe 1
  describe 'onUpdate callback ->', ->
    it 'should be defined', ->
      t = new Timeline onUpdate: ->
      expect(t.o.onUpdate).toBeDefined()
    it 'should call onUpdate callback with the current progress', ->
      t = new Timeline duration: 1000, easing: 'bounce.out', onUpdate: ->
      spyOn t, 'onUpdate'
      t.start()
      t.update t.props.startTime + 500
      expect(t.onUpdate).toHaveBeenCalledWith t.easedProgress
    it 'should have the right scope', ->
      isRightScope = false
      t = new Timeline onUpdate:-> isRightScope = @ instanceof Timeline
      t.start()
      t.update t.props.startTime + 200
      expect(isRightScope).toBe true
  describe 'onStart callback ->', ->
    it 'should be defined', ->
      t = new Timeline(onStart: ->)
      t.start()
      expect(t.o.onStart).toBeDefined()
    it 'should call onStart callback', ->
      t = new Timeline duration: 32, onStart:->
      t.start()
      spyOn(t.o, 'onStart')
      t.update t.props.startTime + 1
      expect(t.o.onStart).toHaveBeenCalled()
    it 'should be called just once', ->
      cnt = 0
      t = new Timeline(duration: 32, onStart:-> cnt++).start()
      t.update(t.props.startTime + 1); t.update(t.props.startTime + 1)
      expect(cnt).toBe 1
    it 'should have the right scope', ->
      isRightScope = false
      t = new Timeline(onStart:-> isRightScope = @ instanceof Timeline)
      t.start()
      t.update t.props.startTime + 1
      expect(isRightScope).toBe true
  describe 'onComplete callback ->', ->
    it 'should be defined', ->
      t = new Timeline onComplete: ->
      expect(t.o.onComplete).toBeDefined()
    it 'should call onComplete callback', ->
      t = new Timeline(duration: 100, onComplete:->).start()
      spyOn(t.o, 'onComplete')
      t.update t.props.startTime + 101
      expect(t.o.onComplete).toHaveBeenCalled()
    it 'should be called just once', ->
      cnt = 0
      t = new Timeline(duration: 32, onComplete:-> cnt++).start()
      t.update(t.props.startTime + 33)
      t.update(t.props.startTime + 33)
      expect(cnt).toBe 1
    it 'should have the right scope', ->
      isRightScope = false
      t = new Timeline
        duration: 1, onComplete:-> isRightScope = @ instanceof Timeline
      t.start().update t.props.startTime + 2
      expect(isRightScope).toBe true
  describe 'yoyo option ->', ->
    it 'should recieve yoyo option', ->
      t = new Timeline yoyo: true
      expect(t.o.yoyo).toBe true
    it 'should toggle the progress direction on repeat', ->
      t = new Timeline(repeat: 2, duration: 10, yoyo: true).start()
      time = t.props.startTime
      t.update(time+1);   expect(t.progress).toBe .1
      t.update(time+5);   expect(t.progress).toBe .5
      t.update(time+10);  expect(t.progress).toBe 1

      t.update(time+11);  expect(t.progress).toBe .9
      t.update(time+15);  expect(t.progress).toBe .5
      t.update(time+19);  expect(parseFloat t.progress.toFixed(1)).toBe .1

      t.update(time+20);  expect(t.progress).toBe 0
      t.update(time+21);  expect(t.progress).toBe .1
      t.update(time+25);  expect(t.progress).toBe .5
      t.update(time+29);  expect(t.progress).toBe .9
      t.update(time+30);  expect(t.progress).toBe 1
      expect(t.isCompleted).toBe true

  describe 'easing ->', ->
    it 'should parse easing string', ->
      t = new Timeline(easing: 'Linear.None')
      expect(typeof t.props.easing).toBe 'function'
    it 'should parse standart easing', ->
      t = new Timeline(easing: 'Sinusoidal.Out', duration: 100)
      t.start(); t.update(t.props.startTime + 50)
      expect(t.easedProgress).toBe easing.Sinusoidal.Out t.progress
    it 'should work with easing function', ->
      easings = one: -> a = 1
      t = new Timeline(easing: easings.one)
      expect(t.props.easing.toString()).toBe easings.one.toString()
    it 'should work with easing function', (dfr)->
      easings = one:(k)-> k
      spyOn easings, 'one'
      t = new Timeline(easing: easings.one)
      t.start(); t.update t.props.startTime + 40
      setTimeout ->
        expect(easings.one).toHaveBeenCalled()
        dfr()
      , 50
  describe 'setProc method->', ->
    it 'should set the current progress', ->
      t = new Timeline(easing: 'Bounce.Out')
      t.setProc .75
      expect(t.progress).toBe .75
      expect(t.easedProgress.toFixed(2)).toBe '0.97'
      








      