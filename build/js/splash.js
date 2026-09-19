(function () {
    var splash = document.getElementById("testVerseSplash");
    var sessionKey = "testverse-splash-shown";
    var homeRoute = "login.jsp";

    if (!splash) {
        return;
    }

    if (sessionStorage.getItem(sessionKey) === "true") {
        window.location.replace(homeRoute);
        return;
    }

    sessionStorage.setItem(sessionKey, "true");

    // Keep the splash visible for exactly three seconds before starting its fade-out.
    window.setTimeout(function () {
        splash.classList.add("is-fading");

        // Redirect after the 300ms CSS transition has completed.
        window.setTimeout(function () {
            window.location.replace(homeRoute);
        }, 300);
    }, 3000);
}());
