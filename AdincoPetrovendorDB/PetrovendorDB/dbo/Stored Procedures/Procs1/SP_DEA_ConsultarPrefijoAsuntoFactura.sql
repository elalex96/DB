USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DEA_ConsultarPrefijoAsuntoFactura'
)
    DROP PROCEDURE SP_DEA_ConsultarPrefijoAsuntoFactura;
GO
/****** Object:  StoredProcedure [dbo].[SP_TA_EnvioCorreosPorNotificacion]    Script Date: 09/03/2022 07:41:36 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: <09/03/2022>
-- Description:	<Consulta de prefijo para asunto de correos de factura DEA>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultarPrefijoAsuntoFactura]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Prefijo VARCHAR(500)

	SELECT  
	@Prefijo = CASE 
	 WHEN RFC = 'DME180322II3'  THEN 'WDMA '
	 WHEN RFC = 'DDE151002QY9'  THEN 'WDM ' 
	 ELSE 
	 '' END 
	FROM S_Proveedor
	WHERE IdProveedor= @IdProveedor

	SELECT ISNULL(@Prefijo,'') as prefijo
END