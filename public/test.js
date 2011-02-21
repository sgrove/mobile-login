$(document).ready(function () {
    return $.mobileLoginify = function (elementId) {
        var isIphone = !equal(navigator.useragent.indexof('iPhone'), 1);
        var $element = $(elementId);
        var $canvas = $('canvas#mobile-login-canvas');
        var ctx = $canvas[0].getcontext('2d');
        var width = $canvas.offset().left;
        var height = $canvas.offset().top;
        var buttonCount = 5;
        var inactive = 0;
        var active = 1;
        var dead = 2;
        var buttons = [];
        var buttonWidth = null;
        var buttonHeight = null;
        var lastButtonTouched = null;
        var lastButtonActive = null;
        var moveList = [];
        var password = null;
        console.log($element);
        $element.append('<canvas id=\'mobile-login-canvas\'>This login methods requires a browser with <canvas> support</canvas>');
        function logArray(item) {
            var logString81 = '';
            var recursiveLog82 = function (arr, level) {
                level = level || 0;
                for (var counter = 0; counter < level; counter += 1) {
                    logString += '\t';
                };
                for (var counter = 0; counter < arr.length; counter += 1) {
                    if (instanceOf(arr[counter], Array)) {
                        recursiveLog(arr[counter], level + 1);
                    } else {
                        logString += arr[counter].toString();
                        logString += '\\n';
                    };
                };
            };
            return recursiveLog(item);
        };
        function logMoves() {
            return logArray(moveList);
        };
        function arrayClone(arr) {
            var a = new(Array());
            for (var property in arr) {
                a[property] = instanceOf(arr[property], Array) ? arrayClone(arr[property]) : arr[property];
            };
            return a;
        };
        function arrayPushUnique(arr, value) {
            for (var counter = 0; counter < arr.length; counter += 1) {
                if (equal(arr[counter], value) || arrayEqual(arr[counter], value)) {
                    return arr;
                };
            };
            return arr.push(value);
        };
        function arrayEqual(a, b) {
            if (!equal(a.length, b.length)) {
                return false;
            };
            for (var counter = 0; counter < a.length; counter += 1) {
                if (!equal(a[counter], b[counter])) {
                    return false;
                };
            };
            return true;
        };
        function uglyRecurseArraysEqualHack(a, b) {
            if (!equal(a.length, b.length)) {
                return false;
            };
            for (var counter = 0; counter < a.length; counter += 1) {
                if (!arrayEqual(a[counter], b[counter])) {
                    return false;
                };
            };
            return true;
        };
        function checkLogin(callBack) {
            var tempMoveList = arrayClone(moveList);
            var tempLastButtonActive = lastButtonActive;
            resetButtons();
            drawWindow();
            if (tempMoveList.length < 0) {
                return null;
            };
            if (password == null) {
                alert('Setting password');
                password = tempMoveList;
                return null;
            };
            if (uglyRecurseArraysEqualHack(tempMoveList, password)) {
                return callBack(true);
            } else {
                return callBack(false);
            };
        };
        function moveContiguouswhat(lastMove, currentMove) {
            if (lastMove == null) {
                return true;
            };
            if (!equal(lastMove[0], currentMove[0]) && !equal(lastMove[1], currentMove[1])) {
                return false;
            };
            if (equal(lastMove[1], currentMove[1]) && !equal(1, Math.abs(lastMove[0] - currentMove[0]))) {
                return false;
            };
            if (equal(lastMove[0], currentMove[0]) && !equal(1, Math.abs(lastMove[1] - currentMove[1]))) {
                return false;
            };
            return true;
        };
        function touchMove($event) {
            $event.preventDefault();
            if (equal($event.originalEvent.length, 1)) {
                var event = $event.originalEvent;
                var touch = (event.touches)[0];
                var $node = $(touch.target);
                var buttonId = positionToButton(touch.pageX, touch.pageY);
                if (buttonId == null) {
                    return null;
                };
                if (moveContiguouswhat(lastButtonActive, buttonId)) {
                    lastButtonTouched = lastButtonTouched || buttonId;
                    if (!arrayEqual(lastButtonTouched, buttonId)) {
                        setButtonState(lastButtonTouched, dead);
                        lashButtonTouched = buttonId;
                    };
                    if (isButtonActive(buttonId)) {
                        lastButtonActive = buttonId;
                        setButtonState(buttonId, active, true);
                        return arrayPushUnique(moveList, buttonId);
                    };
                };
            };
        };
        function setResolution() {
            ctx.canvas.width = ctx.canvas.clientWidth;
            return ctx.canvas.height = ctx.canvas.clientHeight;
        };
        function drawScene() {
            var lineWidth = 2;
            var lineHeight = 2;
            var x = 0;
            var y = 0;
            var buttonWidth = Math.floor(ctx.canvas.width / buttonCount) - lineWidth;
            var buttonHeight = Math.floor(ctx.canvas.height / buttonCount) - lineHeight;
            for (var i = 0; i < buttonCount; i += 1) {
                for (var j = 0; j < buttonCount; j += 1) {
                    x = lineWidth + buttonWidth * i;
                    y = lineHeight + buttonHeight * j;
                    var activeGradient = ctx.createLinearGradient(x, y, x, y + buttonHeight);
                    var deadGradient = ctx.createLinearGradient(x, y, x, y + buttonHeight);
                    var inactiveGradient = ctx.createLinearGradient(x, y, x, y + buttonHeight);
                    activeGradient.addColorStop(0, '#5555FF');
                    activeGradient.addColorStop(1, '#6670FF');
                    deadGradient.addColorStop(0, '#FF5555');
                    deadGradient.addColorStop(1, '#552222');
                    inactiveGradient.addColorStop(0, '#667077');
                    inactiveGradient.addColorStop(1, '#222222');
                    if (equal(active, button[i][j])) {
                        ctx.fillStyle = activeGradient;
                    } else if (equal(dead, button[i][j])) {
                        ctx.fillStyle = deadGradient;
                    } else {
                        ctx.fillStyle = inactiveGradient;
                    };
                    ctx.fillRect(x, y, buttonWidth, buttonHeight);
                };
            };
            ctx.fillStyle = '#99B9CC';
            for (var counter = 0; counter < buttonCount; counter += 1) {
                ctx.fillRect(0, buttonHeight * counter, ctx.canvas.width, lineHeight);
                ctx.fillRect(buttonWidth * counter, 0, lineWidth, ctx.canvas.height);
            };
            ctx.font = 'bold 2em san-serif';
            ctx.fillStyle = 'white';
            for (var i = 0; i < buttonCount; i += 1) {
                for (var j = 0; j < buttonCount; j += 1) {
                    ctx.fillText('*', (lineHeight + buttonWidth * i + buttonWidth / 2) - 9, (lineHeight + buttonHeight * j + buttonHeight / 2) - 10);
                };
            };
        };
        function drawWindow() {
            setResolution();
            return drawScene();
        };
        function positionToButton(x, y) {
            var i = Math.floor(x / buttonWidth);
            var j = Math.floor(y / buttonHeight);
            return [i, j];
        };
        function resetButtons() {
            var buttons = [];
            var moveList = [];
            var lastButtonTouched = null;
            var lastButtonActive = null;
            for (var i = 0; i < buttonCount; i += 1) {
                var row = [];
                for (var j = 0; j < buttonCount; j += 1) {
                    row.push(inactive);
                };
                buttons.push(row);
            };
        };
        var isButton = function (position, state) {
            return equal(state, buttons[position[0]][position[1]]);
        };
        var isButtonMaker = function (value) {
            return function (position) {
                return isButton(position, value);
            };
        };
        var isButtonDead = isButtonMaker(dead);
        var isButtonActive = isButtonMaker(active);
        var isButtonInactive = isButtonMaker(inactive);
        var setButtonState = function (position, state, redraw) {
            buttons[position[0]][position[1]] = state;
            if (equal(redraw, true)) {
                return drawWindow();
            };
        };
        $('window').bind('resize', drawWindow);
        $('#container').bind('touchmove', touchMove);
        $('#container').bind('touchend', function () {
            return checkLogin(function (result) {
                if (result) {
                    return alert('Logged in!');
                } else {
                    return alert('Couldn\'t log in.');
                };
            });
        });
        resetButtons();
        return drawWindow();
    };
});