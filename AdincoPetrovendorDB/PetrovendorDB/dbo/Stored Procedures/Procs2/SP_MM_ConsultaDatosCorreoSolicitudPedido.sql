/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaDatosCorreoSolicitudPedido]    Script Date: 28/09/2020 14:13:08 ******/
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/09/2020>
-- Description:	<Consulta de datos de solicitud de pedido para evitar errores en campos vacios>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaDatosCorreoSolicitudPedido] 
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 DECLARE @NombreAreaContractual NVARCHAR(MAX)  
	 DECLARE @NumeroContrato NVARCHAR(MAX)  
	 DECLARE @Contrato NVARCHAR(MAX) 
	 DECLARE @Mensaje VARCHAR(MAX);
  
  
	SELECT DISTINCT  
			@NombreAreaContractual=ISNULL(AC.NombreAreaContractual,''),  
			@NumeroContrato=ISNULL(C.NumeroContrato,''),  
			@Contrato=(CONCAT(ISNULL(C.NumeroContrato,''),' - ',ISNULL(AC.NombreAreaContractual,''))),
			@Mensaje = ISNULL(OP.Descripcion,'')   
	FROM Adinco.dbo.CO_Contrato C  (NOLOCK)
	  LEFT JOIN Adinco.dbo.CO_AreaContractual AC  (NOLOCK)
			ON C.IdAreaContractual = AC.IdAreaContractual  
	  LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido SP (NOLOCK)
			ON sp.IdContrato= C.IdContrato  
	  LEFT JOIN dbo.TA_Operacion AS OP (NOLOCK)
			ON OP.IdDocumento = SP.IdSolicitudPedido
			AND OP.IdTipoOperacion = 2
			AND OP.IdProveedor = SP.IdProveedor
	WHERE (SP.IdSolicitudPedido = @IdSolicitudPedido);  
   
	SELECT   
	ISNULL(@NombreAreaContractual,'') AS NombreAreaContractual,  
	ISNULL(@NumeroContrato,'') AS NombreAreaContractual,  
	ISNULL(@Contrato,'') AS Contrato,
	@Mensaje AS Mensaje

END