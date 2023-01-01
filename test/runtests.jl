using TestItems
using TestItemRunner
@run_package_tests


@testitem "_" begin
    import Aqua
    Aqua.test_all(SentinelViews; ambiguities=false)
    Aqua.test_ambiguities(SentinelViews)

    import CompatHelperLocal as CHL
    CHL.@check()
end
