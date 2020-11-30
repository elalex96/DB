-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28-06-2019>
-- Description:	<Consultar los de ventas del proveedor>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AP_CN_ConsultarVentasProveedor] 
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IDPROVEEDOR INT = (SELECT 
									P.IdSubcontratista
								FROM dbo.MM_AceptacionPedido AS AP
									LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
								WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);


	CREATE TABLE #CONTACTOS(
	IdContacto INT,
	Nombre NVARCHAR(MAX),
	Email NVARCHAR(MAX),
	Telefono NVARCHAR(MAX)
	);

	INSERT INTO #CONTACTOS
	SELECT 
		CPA.IdContacto, 
		ISNULL(CPA.Nombres,'') + ISNULL(CPA.Apellidos,''),
		CPA.Email,
		CPA.Telefono
	from S_Contacto_PA CPA
	where CPA.IdProveedor = @IDPROVEEDOR and CPA.IsEliminado = 0 AND CPA.IdTipoContacto = 1;

	INSERT INTO #CONTACTOS
	SELECT
		US.IdUsuario,
		US.Nombre,
		US.Correo,
		US.Telefono
	FROM dbo.S_Usuario AS US
	LEFT JOIN dbo.S_UsuarioProveedor AS USPR ON USPR.IdUsuario = US.IdUsuario
	WHERE USPR.IdProveedor = @IDPROVEEDOR AND US.IdTipoUsuario = 3;

	SELECT 
		IdContacto,
		Nombre,
		Email,
		Telefono
	FROM #CONTACTOS;

END
