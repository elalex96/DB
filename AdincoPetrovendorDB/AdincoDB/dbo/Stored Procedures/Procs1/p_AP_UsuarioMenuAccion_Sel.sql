IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_AP_UsuarioMenuAccion_Sel'
    )
    DROP PROCEDURE p_AP_UsuarioMenuAccion_Sel;
GO
CREATE PROCEDURE p_AP_UsuarioMenuAccion_Sel --'../../2/Subcontratos/ConsultaSubcontrato.aspx', 10527
    @pUrl       varchar(250),
    @pUsuarioId int
as
    BEGIN
        SELECT
            ma.IdUsuario,
            ma.MenuDId,
            ma.IdAccion,
            ma.Permitir,URL
        FROM
            [dbo].[AP_UsuarioMenuAccion] ma (NOLOCK)
        JOIN
            [dbo].[AP_MenuD]         m (NOLOCK)
            ON  ma.IdUsuario = @pUsuarioId
            AND 
				ma.MenuDId = m.MenuId
        WHERE
            Url LIKE '%' + isnull(@pUrl, '') + '%';

    END