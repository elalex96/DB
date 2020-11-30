
-- =============================================
-- Author:		<AlexanderG>
-- Create date: <11-09-2017>
-- Description:	<Consultar Cantidades de Proveedores Registrados, Activos e Inactivos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_CantidadUsuarios] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;
	

    -- Insert statements for procedure here
	DECLARE @UR INT = (SELECT COUNT(IdUsuario) FROM S_Usuario) 
	DECLARE @UA INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE Activo = 1)
	DECLARE @UI INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE Activo = 0)
	DECLARE @UP INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE IdTipoUsuario = 2)
	DECLARE @UAD INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE IdTipoUsuario = 3)
	DECLARE @UV INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE IdTipoUsuario = 4)
	DECLARE @UC INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE IdTipoUsuario = 5)
	DECLARE @UF INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE IdTipoUsuario = 6)
	DECLARE @UDG INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE IdTipoUsuario = 7)
	DECLARE @UROOT INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE IdTipoUsuario = 8)
	DECLARE @UREQ INT = (SELECT COUNT(IdUsuario) FROM S_Usuario WHERE IdTipoUsuario = 9)

	SELECT 
	@UR AS REGISTRADOS, 
	@UA AS ACTIVOS, 
	@UI AS INACTIVOS,
	@UP AS PROVEEDORES,
	@UAD AS ADMINISTRADORES,
	@UV AS VENTAS,
	@UC AS COMPRAS,
	@UF AS FINANZAS,
	@UDG AS DIRECCIONGENERAL,
	@UROOT AS ROOOT,
	@UREQ AS REQUISITOR
END


