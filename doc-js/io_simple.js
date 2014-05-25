require(["jquery","cs!seq", "cs!input/fasta"], function ($, Seq, Fasta) {
  var a_sequence = new Seq("ACGT");
  $("#ele").append("rvs_complement  " + a_sequence.reverse_complement() + "\n");
  $("#ele").append("Transcribe:     " + a_sequence.transcribe()+ "\n");
  $("#ele").append("Back_Transcribe " + a_sequence.back_transcribe()+ "\n");
  $("#ele").append("Translate       " + a_sequence.translate()+ "\n");
  $("#ele").append("Ungap           " + a_sequence.ungap()+ "\n");

  // as a async, non-blocking call
  Fasta.read("dummy/S5G603.fasta", function(fasta) {
    $("#ele").append("\n Dummy FASTA: \n" + fasta.toString()+ "\n");
  });

});
