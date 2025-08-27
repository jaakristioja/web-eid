#
# Copyright (c) 2023 Jaak Ristioja
#
# SPDX-License-Identifier: MIT
#

EAPI=8

inherit cmake

GIT_REV='a717afc2f16e02069e527ba4607b34662ae6b1e6'
DESCRIPTION="Performs cryptographic operations for the Web eID browser extension"
HOMEPAGE="https://github.com/web-eid/web-eid-app"
SRC_URI="https://github.com/web-eid/${PN}/archive/${GIT_REV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/libelectronic-id
	dev-qt/qtbase:6
	dev-qt/qtsvg:6
	dev-qt/qttools:6
	sys-apps/pcsc-lite
"

DEPEND="${RDEPEND}
	dev-cpp/magic_enum
	dev-libs/libelectronic-id
"

PATCHES=(
	"${FILESDIR}"/${P}-no-submodules.patch
)

S="${WORKDIR}/${PN}-${GIT_REV}"

src_prepare() {
	cmake_src_prepare

	# Use system dev-cpp/magic_enum:
	sed -i -e 's%"magic_enum/magic_enum.hpp"%<magic_enum/magic_enum.hpp>%' \
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

	# Disable tests
	cmake_comment_add_subdirectory tests/mock-ui
	cmake_comment_add_subdirectory tests/tests
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
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
