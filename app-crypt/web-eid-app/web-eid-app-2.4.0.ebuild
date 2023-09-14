#
# Copyright (c) 2023 Jaak Ristioja
#
# SPDX-License-Identifier: MIT
#

EAPI=8

inherit cmake

DESCRIPTION="Performs cryptographic operations for the Web eID browser extension"
HOMEPAGE="https://github.com/web-eid/web-eid-app"
SRC_URI="https://github.com/web-eid/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/libelectronic-id
	dev-qt/qtbase:6
	dev-qt/qtsvg:6
	dev-qt/qttools:6
	sys-apps/pcsc-lite
"

DEPEND="${RDEPEND}
	dev-cpp/magic_enum
	dev-libs/libelectronic-id[test=]

	test? (
		dev-libs/libpcsc-mock
		dev-cpp/gtest
	)
"

PATCHES=(
	"${FILESDIR}"/${P}-tests-optional.patch
)

src_prepare() {
	cmake_src_prepare

	# Force use of Qt6:
	sed -i -e 's/QT NAMES Qt6 Qt5/QT NAMES Qt6/' CMakeLists.txt

	# Use system dev-cpp/magic_enum:
	sed -i -e 's%"magic_enum/magic_enum.hpp"%<magic_enum.hpp>%' \
		src/controller/command-handlers/certificatereader.cpp \
		src/controller/commands.cpp \
		src/controller/retriableerror.cpp

	# Build a object libraries instead of static libraries for internal use:
	find . -name CMakeLists.txt -exec sed -i -e 's/STATIC/OBJECT/' {} \;

	# Use system dev-libs/libelectronic-id:
	cmake_comment_add_subdirectory lib/libelectronic-id

	# Link to dev-libs/pcsc-cpp:
	sed -i -e 's/target_link_libraries(web-eid controller ui pcsc)/'`
		`'target_link_libraries(web-eid controller ui pcsc-cpp)/' \
		src/app/CMakeLists.txt

	if use test; then
		# Add missing link library:
		sed -i -e 's/target_link_libraries(web-eid-tests /'`
			`'target_link_libraries(web-eid-tests pcsc-cpp /' \
			tests/tests/CMakeLists.txt

		# Fix test includes:
		sed -i \
			-e 's%"select-certificate-script.hpp"%'`
			`'<electronic-id/test/select-certificate-script.hpp>%' \
			-e 's%"atrs.hpp"%<electronic-id/test/atrs.hpp>%' \
			tests/tests/main.cpp
	fi
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}

src_test() {
	local -x QT_QPA_PLATFORM="offscreen"
	cmake_src_test
}

src_install() {
	dodoc LICENSE README.md
	cmake_src_install
}
