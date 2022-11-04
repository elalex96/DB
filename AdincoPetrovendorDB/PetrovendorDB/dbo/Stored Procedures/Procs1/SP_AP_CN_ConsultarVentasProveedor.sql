USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_AP_CN_ConsultarVentasProveedor'
)
    DROP PROCEDURE SP_AP_CN_ConsultarVentasProveedor;
GO
/****** Object:  StoredProcedure [dbo].[SP_AP_CN_ConsultarVentasProveedor]    Script Date: 31/10/2022 05:51:29 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28-06-2019>
-- Description:	<Consultar los de ventas del proveedor>
-- DAC- No retornar usuarios inactivos ni repetidos 31/10/2022
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
								FROM dbo.MM_AceptacionPedido AS AP (NOLOCK)
								JOIN dbo.MM_Pedido AS P (NOLOCK)
									ON AP.IdPedido = P.IdPedido 
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
	from S_Contacto_PA CPA  (NOLOCK)
	where CPA.IdProveedor = @IDPROVEEDOR 
	AND CPA.IsEliminado = 0 
	AND CPA.IdTipoContacto = 1; --> CTE VENTAS
	

	INSERT INTO #CONTACTOS
	SELECT
		US.IdUsuario,
		US.Nombre,
		US.Correo,
		US.Telefono
	FROM dbo.S_Usuario AS US  (NOLOCK)
	JOIN dbo.S_UsuarioProveedor AS USPR   (NOLOCK)
		ON US.IdUsuario = USPR.IdUsuario 
	LEFT JOIN #CONTACTOS C1
		ON RTRIM(LTRIM(LOWER(US.Correo))) COLLATE Modern_Spanish_CI_AS = RTRIM(LTRIM(LOWER(C1.Email)))  COLLATE Modern_Spanish_CI_AS
	WHERE USPR.IdProveedor = @IDPROVEEDOR
	AND Activo = 1 --> CTE ACTIVO
	AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4) --> CTE Ventas/Administrador
	AND C1.IdContacto IS NULL; --> PARA EVITAR REPETIR LOS MISMO CORREOS 


	SELECT 
		IdContacto,
		Nombre,
		RTRIM(LTRIM(LOWER(Email))) AS Email,
		Telefono
	FROM #CONTACTOS;

END
