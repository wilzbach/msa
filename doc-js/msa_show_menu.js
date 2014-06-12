require(["cs!msa/msa", "cs!msa/menu/defaultmenu"], function (MSA, DefaultMenu) {

  var msa = new MSA('msa-show-menu');
  msa.addDummySequences();

  // the menu is independent to the MSA container
  var defMenu = new DefaultMenu("msa-show-menubar", msa);
  defMenu.createMenu();
});
