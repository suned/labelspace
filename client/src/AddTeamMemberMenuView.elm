module AddTeamMemberMenuView exposing (modal, update)

import AddTeamMemberMenu
import AppModel
import AppMsg
import Bulma
import Html.Styled as Html


modal model =
    let
        isOpen =
            True

        title =
            "Add Team Member"

        body =
            Html.div [] []

        footer =
            [ Html.div [] [] ]
    in
    Bulma.modal isOpen title (AppMsg.AddTeamMemberMenuMsg AppMsg.ToggleAddTeamMemberMenu) body footer


update : AppMsg.AddTeamMemberMenuMsg -> AppModel.Model -> ( AppModel.Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        AppMsg.ToggleAddTeamMemberMenu ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.toggle |> AppModel.asAddTeamMemberMenu model, Cmd.none )

        AppMsg.SetEmail email ->
            ( model.addTeamMemberMenu |> AddTeamMemberMenu.setEmail email |> AppModel.asAddTeamMemberMenu model, Cmd.none )

        AppMsg.SaveTeamMember ->
            ( model, Cmd.none )
