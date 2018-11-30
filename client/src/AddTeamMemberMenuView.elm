module AddTeamMemberMenuView exposing (modal, update)

import AddTeamMemberMenu
import AppModel
import AppMsg
import Bulma
import Html.Styled as Html
import Html.Styled.Events as Events


modal model =
    let
        title =
            "Add Team Member"

        body =
            Bulma.labelledField "email" [ Bulma.textInput [ Events.onInput (AppMsg.AddTeamMemberMenuMsg << AppMsg.SetEmail) ] ]

        footer =
            [ Bulma.button [ Events.onClick (AppMsg.AddTeamMemberMenuMsg AppMsg.SaveTeamMember) ] "invite" ]
    in
    Bulma.modal model.isOpen title (AppMsg.AddTeamMemberMenuMsg AppMsg.ToggleAddTeamMemberMenu) body footer


update : AppMsg.AddTeamMemberMenuMsg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        AppMsg.ToggleAddTeamMemberMenu ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.toggle |> AppModel.asAddTeamMemberMenu model, Cmd.none )

        AppMsg.SetEmail email ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.setEmail email |> AppModel.asAddTeamMemberMenu model, Cmd.none )

        AppMsg.SaveTeamMember ->
            Debug.todo "save team member"
