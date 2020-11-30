-- =============================================
-- Author:		Reyna Olvera
-- Create date: 06/02/2018
-- Description:	Acceso a paginas 
-- =============================================
CREATE PROCEDURE [dbo].[SP_AP_SeguridadPaginaXRol]
	-- Add the parameters for the stored procedure here
@idRol      INT,
@idContrato INT,
@idUsuario  INT,
@Pagina varchar(Max)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	if(@idRol=1)
	begin
		Select count(*)  FROM AP_MenuPorRol MR
                          JOIN AP_MenuN M ON M.MenuId = MR.IdMenu;
	--										WHERE MR.Visible = 1
	--										  AND MR.IdRol = @idRol;
	end

	else 
	if(@Pagina='default.aspx' OR @Pagina='PaginaSinPermiso.aspx' Or @Pagina='AdministracionMenu.aspx')
 Begin
	SELECT count( M.archivo)
                     FROM AP_MenuPorRol MR
                          JOIN AP_MenuN M ON M.MenuId = MR.IdMenu
											 --WHERE MR.Visible = 1
												--   AND MR.IdRol =@idRol;
 end

 else
 begin 
	 SELECT count( M.archivo)
                     FROM AP_MenuPorRol MR
                          JOIN AP_MenuN M ON M.MenuId = MR.IdMenu
											 WHERE MR.Visible = 1
												   AND MR.IdRol = @idRol And M.archivo Like '%'+@Pagina;
end

END

