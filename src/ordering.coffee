module.exports =
  class Ordering

    constructor: ->
      @sorter = Ordering.orderID
      @reverse = false

    # customize the sorting
    # @param type [function] e.g. Ordering.orderID, Ordering.orderName
    # your custom function could look like this:
    # function(seqs, ordering){
    #   return ordering.sort();
    # }
    setSort: (sort) ->
      unless sort?
        console.log "Hey I don't like empty pointers. Please specify a valid sorter"
      else
        @sorter = sort

    # sets the reverse method
    # @param reverse [boolean] whether the array should be sorted in reverse
    setReverse: (reverse) ->
      @reverse = reverse

    # using last known ordering type
    # this method is called by the MSA viewer
    # so you need to save your properties
    calcSeqOrder: (seqs) =>
      Ordering._orderSeqsAfterScheme seqs, @sorter, @reverse

    # uses a predefined schema to order sequences
    # @param seqs [[Sequences]] all sequence to sort = dictionary of all rows
    # @param type [function] sort function: e.g. Ordering.numeric,Ordering.alphabetic
    # @param reverse [boolean] (optional) reversed the sorted array
    # @returns sorted array of the seqids
    @_orderSeqsAfterScheme = (seqs, sorter, reverse) ->

      ordering = []
      for key,seq of seqs
        ordering.push key

      ordering = sorter seqs,ordering

      if ordering.length is 0
        throw "invalid type selected. component will crash."
        return []

      #check whether we have to reverse the array
      if reverse
        return ordering.reverse()
      else
        return ordering

    # orders after seq id
    @orderID: (seqs, ordering) ->
        return ordering.sort();

    # sorts after the sequence name
    @orderName: (seqs, ordering) ->
      ordering.sort (a, b) ->
        nameA = seqs[a].tSeq.name
        nameB = seqs[b].tSeq.name
        if nameA < nameB
          -1
        else if nameA > nameB
          1
        else
          0
    # sorts after the sequence
    @orderSeq: (seqs, ordering) ->
      ordering.sort (a, b) ->
        nameA = seqs[a].tSeq.seq
        nameB = seqs[b].tSeq.seq
        if nameA < nameB
          -1
        else if nameA > nameB
          1
        else
          0
