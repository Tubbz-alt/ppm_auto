#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/pkg_chooser.sh
#configure package manager
#110118 alternate user interfaces.
#120203 BK: internationalized.
#120210 01micko: Ziggy ui crashes if *all* repos unticked here (no one would do that, but it is still a bug).
#120515 in some cases, Packages-puppy-${DISTRO_FILE_PREFIX}-* may not exist (ex, Racy only has Packages-puppy-wary5-official).
#120529 checkbox to display app thumbnail icons.
#120811 category field now supports sub-category |category;subcategory|, use as icon in ppm main window. -- always enabled.
#121102 Packages-puppy-${DISTRO_FILE_PREFIX}- (or Packages-puppy-${DISTRO_COMPAT_VERSION}-) is now Packages-puppy-${DISTRO_DB_SUBNAME}-. refer /etc/DISTRO_SPECS.
#121129 Update: d/l Packages-puppy-squeeze-official, which wasn't there before, upset this script.

export TEXTDOMAIN=petget___configure.sh
export OUTPUT_CHARSET=UTF-8

#export LANG=C
. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS
. /root/.packages/DISTRO_PET_REPOS
. /root/.packages/PKGS_MANAGEMENT #has PKG_REPOS_ENABLED

#find what repos are currently in use... 120510...
CHECKBOXES_REPOS=""
#for ONEREPO in `ls -1 /root/.packages/Packages-*`
#120510 bugfix with ui_Ziggy. add CHECKBOX_MAIN_REPO var to gui
MAIN_REPO="`ls -1 /root/.packages/Packages-* | grep "puppy\-${DISTRO_DB_SUBNAME}\-" | head -n 1 | sed 's%^/root/.packages/%%'`" #121102 121129
#120515 hmmm, in some cases, Packages-puppy-${DISTRO_FILE_PREFIX}-* may not exist (ex, Racy only has Packages-puppy-wary5-official)...
#121102 ...now using DISTRO_DB_SUBNAME, should always exist.
[ "$MAIN_REPO" = "" ] && MAIN_REPO="`echo "$PACKAGELISTS_PET_ORDER" | tr ' ' '\n' | head -n 1`" #PACKAGELISTS_PET_ORDER is in /root/.packages/DISTRO_PET_REPOS.
[ "$MAIN_REPO" = "" ] && MAIN_REPO="Packages-puppy-noarch-official" #paranoid precaution.
bMAIN_PATTERN=' '"$MAIN_REPO"' '
MAIN_DBNAME="`echo -n "$MAIN_REPO" | sed -e 's%Packages\-%%'`"
CHECKBOX_MAIN_REPO="<checkbox><default>true</default><label>${MAIN_DBNAME}</label><variable>CHECK_${MAIN_DBNAME}</variable><visible>disabled</visible></checkbox>" #hard coded "true"

DBFILESLIST="$(ls -1 /root/.packages/Packages-*)" #121129

PKG_REPOS_ENABLED=" ${PKG_REPOS_ENABLED} " #121129 precaution.
for ONEREPO in `echo "$DBFILESLIST" | grep -v "${MAIN_REPO}" | tr '\n' ' '` #120515 fix. 121129
do
 BASEREPO="`basename $ONEREPO`"
 bPATTERN=' '"${BASEREPO}"' '
 DEFAULT='true'
 [ "`echo -n "$PKG_REPOS_ENABLED" | grep "$bPATTERN"`" = "" ] && DEFAULT='false'
 DBNAME="`echo -n "$BASEREPO" | sed -e 's%Packages\-%%'`"
 CHECKBOXES_REPOS="${CHECKBOXES_REPOS}<checkbox><default>${DEFAULT}</default><label>${DBNAME}</label><variable>CHECK_${DBNAME}</variable></checkbox>"
done

#110118 choose a user interface...
#UI="`cat /var/local/petget/ui_choice`"
#[ "$UI" = "" ] && UI="Ziggy"
#UI_RADIO="<radiobutton><label>${UI}</label><action>echo -n ${UI} > /var/local/petget/ui_choice</action></radiobutton>"
#for ONEUI in Classic Ziggy
#do
# [ "$ONEUI" = "$UI" ] && continue
# UI_RADIO="${UI_RADIO}<radiobutton><label>${ONEUI}</label><action>echo -n ${ONEUI} > /var/local/petget/ui_choice</action></radiobutton>"
#done


S='<window title="'$(gettext 'Puppy Package Manager - Configure')'" icon-name="gtk-about">
<vbox space-expand="true" space-fill="true">
<notebook tab-pos="2" labels="'$(gettext 'Choose repositories')'|'$(gettext 'Update database')'|'$(gettext 'Misc')'" space-expand="true" space-fill="true">
  <vbox space-expand="true" space-fill="true">
    <frame '$(gettext 'Choose repositories')'>
      <vbox space-expand="false" space-fill="false">
        <hbox space-expand="true" space-fill="true">
          <text xalign="0" space-expand="true" space-fill="true"><label>"'$(gettext "Choose what repositories you would like to have appear in the main GUI window.")'"</label></text>
          <button image-position="2" tooltip-text="'$(gettext 'Adding a new repository currently requires manual editing of some text files. Click this button for further information:')'" space-expand="false" space-fill="false">
            '"`/usr/lib/gtkdialog/xml_button-icon help`"'
            <label>" '$(gettext 'Add new repo')'"</label>
            <action>nohup defaulthtmlviewer file:///usr/local/petget/README-add-repo.htm & </action>
          </button>
        </hbox>
      </vbox>
      <vbox space-expand="true" space-fill="true">
        <vbox scrollable="true" shadow-type="1">
          '${CHECKBOXES_REPOS}'
          '${CHECKBOX_MAIN_REPO}'
        </vbox>
      </vbox>
    </frame>
  </vbox>

  <vbox space-expand="true" space-fill="true">
    <frame '$(gettext 'Update database')'>
  <vbox space-expand="false" space-fill="false">
      
      <hbox space-expand="true" space-fill="true">
        <text xalign="0" space-expand="true" space-fill="true"><label>'$(gettext 'Puppy has a database file for each package repository. This downloads the latest information on what packages are in the repository')'</label></text>
        <button image-position="2" space-expand="false" space-fill="false">
          '"`/usr/lib/gtkdialog/xml_button-icon refresh`"'
          <label>'$(gettext 'Update now')'</label>
          <action>rxvt -bg yellow -title "download databases" -e /usr/local/petget/0setup</action>
        </button>
      </hbox>
      <text space-expand="true" space-fill="true"><label>""</label></text>
      <hbox space-expand="true" space-fill="true">
        <hbox space-expand="false" space-fill="false">
          <vbox space-expand="true" space-fill="true">
            '"`/usr/lib/gtkdialog/xml_pixmap nb.svg`"'
          </vbox>
        </hbox>
        <text xalign="0" yalign="0" space-expand="true" space-fill="true"><label>'$(gettext "Warning: The database information for some repositories is quite large, about 1.5MB for 'slacky' and several MB for Ubuntu/Debian. If you are on dialup, be prepared for this.")'</label></text>
      </hbox>
      </vbox>
      <expander>
        <vbox space-expand="true" space-fill="true">
          <hbox space-expand="true" space-fill="true">
            <hbox space-expand="false" space-fill="false">
              <vbox space-expand="true" space-fill="true">
                '"`/usr/lib/gtkdialog/xml_pixmap info.svg`"'
              </vbox>
            </hbox>
            <text xalign="0" space-expand="true" space-fill="true"><label>'$(gettext "Some repositories are 'fixed' and do not need to be updated. An example of this is the Slackware official version 12.2 repo. An example that does change is the Slackware 'slacky' 12.2 repo which has extra packages for Slackware 12.2. Anyway, to be on the safe side, clicking the above button will update all database files.")'</label></text>
          </hbox>
          <hbox space-expand="true" space-fill="true">
            <hbox space-expand="false" space-fill="false">
              <vbox space-expand="true" space-fill="true">
                '"`/usr/lib/gtkdialog/xml_pixmap info.svg`"'
              </vbox>
            </hbox>
            <text xalign="0" space-expand="true" space-fill="true"><label>'$(gettext 'Technical note: if you would like to see the package databases, they are at')' /root/.packages/Packages-*. '$(gettext 'These are in a standardised format, regardless of which distribution they were obtained from. This format is considerably smaller than that of the original distro.')'</label></text>
          </hbox>
        </vbox>
        <label>'$(gettext 'More info')'</label>
      </expander>
      <text space-expand="true" space-fill="true"><label>""</label></text>
    </frame>
  </vbox>

  <vbox space-expand="true" space-fill="true">
    <frame '$(gettext 'Misc')'>
      <checkbox>
        <label>'$(gettext "Enable BuildingBlock category (for advanced users only!)")'</label>
        <variable>CATEGORY_BB</variable>'
        [ "$(</var/local/petget/bb_category)" = "true" ] && S=$S'<default>true</default>'
      S=$S'</checkbox>
    </frame>
  </vbox>
</notebook>

<vbox space-expand="false" space-fill="false">
  <hbox space-expand="true" space-fill="true">
    <text space-expand="true" space-fill="true"><label>""</label></text>
    <hbox space-expand="false" space-fill="false">
      <button>
        '"`/usr/lib/gtkdialog/xml_button-icon cancel`"'
        <label>" '$(gettext 'Cancel')' "</label>
        <action>EXIT:cancel</action>
      </button>
      <button>
        '"`/usr/lib/gtkdialog/xml_button-icon ok`"'
        <label>" '$(gettext 'Ok')' "</label>
        <action>EXIT:OK</action>
      </button>
      '"`/usr/lib/gtkdialog/xml_scalegrip`"'
    </hbox>
  </hbox>
</vbox>
</vbox>
</window>'
export PPM_CONFIG="$S"

#echo "$PPM_CONFIG" > /root/gtk

RETPARAMS="`gtkdialog -p PPM_CONFIG`"
#ex:
#  CHECK_puppy-2-official="false"
#  CHECK_puppy-3-official="true"
#  CHECK_puppy-4-official="true"
#  CHECK_puppy-woof-official="false"
#  CHECK_ubuntu-intrepid-main="true"
#  CHECK_ubuntu-intrepid-multiverse="true"
#  CHECK_ubuntu-intrepid-universe="true"
#  EXIT="OK"

[ "`echo -n "$RETPARAMS" | grep 'EXIT' | grep 'OK'`" = "" ] && exit
echo -n "$RETPARAMS" | grep 'CATEGORY_BB' | cut -d= -f2 | tr -d '"' > /var/local/petget/bb_category
enabledrepos=" "
#repocnt=1
for ONEREPO in `echo "$DBFILESLIST" | tr '\n' ' '` #121129
do
 REPOBASE="`basename $ONEREPO`"
 repoPATTERN="`echo -n "$REPOBASE" | sed -e 's%Packages\\-%%' | sed -e 's%\\-%\\\\-%g'`"
 if [ "`echo "$RETPARAMS" | grep "$repoPATTERN" | grep 'false'`" = "" ];then
  enabledrepos="${enabledrepos}${REPOBASE} "
#  repocnt=`expr $repocnt + 1`
#  [ $repocnt -gt 5 ] && break #only allow 5 active repos in PPM.
 fi
done
grep -v '^PKG_REPOS_ENABLED' /root/.packages/PKGS_MANAGEMENT > /tmp/pkgs_management_tmp2
mv -f /tmp/pkgs_management_tmp2 /root/.packages/PKGS_MANAGEMENT
echo "PKG_REPOS_ENABLED='${enabledrepos}'" >> /root/.packages/PKGS_MANAGEMENT

for I in `grep -E "PPM_GUI|pkg_chooser" <<< "$(ps -eo pid,command)" | awk '{print $1}' `; do kill -9 $I; done
/usr/local/petget/pkg_chooser.sh &

###END###
