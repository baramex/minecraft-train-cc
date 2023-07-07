function terminate()
    os.pullEventRaw("terminate")
    os.reboot()
end

function startup()
    shell.run("script.lua")
end

parallel.waitForAll(startup,terminate)
