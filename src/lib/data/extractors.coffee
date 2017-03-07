_ = require('lodash')._

extractCharacter = (character) ->
  powerLevel = character.powerLevel
  gender = character.gender.genderType == 1 && character.race.raceNameFemale || character.race.raceNameMale
  className = character.characterClass.className

  "#{gender} #{className} (#{powerLevel})"

extractCharacters = (characters) ->
  _.transform(characters, ((result, character) -> result[character.characterId] = extractCharacter(character)), {})

module.exports = {
  member: (name, bungieAccount) ->
    account = bungieAccount.destinyAccounts[0]
    return {
      name: account.userInfo.displayName,
      membershipId: account.userInfo.membershipId,
      membershipType: account.userInfo.membershipType,
      clan: if bungieAccount.clans.length > 0 then bungieAccount.relatedGroups[bungieAccount.clans[0].groupId].name else '',
      characters: extractCharacters(account.characters),
      lastCharacter: account.characters[0].characterId
    }
}