package com.hopenvision.architecture;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

import static com.tngtech.archunit.library.Architectures.layeredArchitecture;

/**
 * Modular Monolith 경계 규칙 검증.
 *
 * <p>각 모듈(identity/content/enrollment/order/point/book/platform)은
 * 상위 의존 방향만 허용한다. 하위 모듈이 상위 모듈을 import 하면 빌드 실패.
 *
 * <p>기존 모듈(admin, user, exam, auth, config)은 베이스라인으로 규칙 대상에서 제외.
 * 점진 이관 과정에서 규칙을 좁힌다.
 */
@AnalyzeClasses(
        packages = "com.hopenvision",
        importOptions = ImportOption.DoNotIncludeTests.class
)
class ModuleBoundaryTest {

    private static final String ID  = "com.hopenvision.identity..";
    private static final String CT  = "com.hopenvision.content..";
    private static final String EN  = "com.hopenvision.enrollment..";
    private static final String OD  = "com.hopenvision.order..";
    private static final String PT  = "com.hopenvision.point..";
    private static final String BK  = "com.hopenvision.book..";
    private static final String PL  = "com.hopenvision.platform..";

    /**
     * 계층 의존 방향:
     *   platform  ←  identity  ←  content  ←  {enrollment, order, point, book}
     *
     * 같은 층 또는 상위 층으로의 역참조는 금지.
     */
    @ArchTest
    static final ArchRule mvp_module_layering =
            layeredArchitecture().consideringOnlyDependenciesInAnyPackage("com.hopenvision..")
                    // Sprint 0: identity 외 모듈은 skeleton 상태 → 빈 레이어 허용
                    .withOptionalLayers(true)
                    .layer("platform").definedBy(PL)
                    .layer("identity").definedBy(ID)
                    .layer("content").definedBy(CT)
                    .layer("enrollment").definedBy(EN)
                    .layer("order").definedBy(OD)
                    .layer("point").definedBy(PT)
                    .layer("book").definedBy(BK)

                    .whereLayer("platform").mayOnlyBeAccessedByLayers(
                            "identity", "content", "enrollment", "order", "point", "book")
                    .whereLayer("identity").mayOnlyBeAccessedByLayers(
                            "content", "enrollment", "order", "point", "book")
                    .whereLayer("content").mayOnlyBeAccessedByLayers(
                            "enrollment", "order", "book")
                    // 상위 모듈 간 직접 참조 금지 (이벤트로만 소통)
                    .whereLayer("enrollment").mayNotBeAccessedByAnyLayer()
                    .whereLayer("order").mayOnlyBeAccessedByLayers("enrollment", "point", "book")
                    .whereLayer("point").mayOnlyBeAccessedByLayers("order")
                    .whereLayer("book").mayOnlyBeAccessedByLayers("order");
}
