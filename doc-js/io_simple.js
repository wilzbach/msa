require(["jquery","cs!seq", "cs!input/fasta"], function ($, Seq, Fasta) {
  var a_sequence = new Seq("ACGT");
  $("#ele").append("rvs_complement  " + a_sequence.reverse_complement() + "\n");
  $("#ele").append("Transcribe:     " + a_sequence.transcribe()+ "\n");
  $("#ele").append("Back_Transcribe " + a_sequence.back_transcribe()+ "\n");
  $("#ele").append("Translate       " + a_sequence.translate()+ "\n");
  $("#ele").append("Ungap           " + a_sequence.ungap()+ "\n");

  // uniprot does not support SSL requests
  var dummyFasta = new Fasta("dummy/S5G603.fasta");
  $("#ele").append("\n Dummy FASTA: \n" + dummyFasta.toString()+ "\n");

});
