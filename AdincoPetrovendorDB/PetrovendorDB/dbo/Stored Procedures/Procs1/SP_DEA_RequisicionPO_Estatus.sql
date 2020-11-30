-- =============================================
-- Author:        Daniel AC
-- Create date: 27/04/2018
-- Description:    Agregar referencia a  documentos 
CREATE  PROCEDURE [dbo].[SP_DEA_RequisicionPO_Estatus] --420,0,18660
    -- Add the parameters for the stored procedure here
    
    @IdProveedor INT,
    @IdUsuario INT,
    @IdSolicitudPedido INT    


AS
    
BEGIN                
    
   DECLARE @ESTATUS_ACTUAL_SOLPED INT 
   DECLARE @HAY_DOCUMENTO_PR INT
    


   SELECT @ESTATUS_ACTUAL_SOLPED= IdEstatusOperacion 
   FROM dbo.MM_SolicitudPedido SP
   LEFT JOIN dbo.TA_Operacion  O ON O.IdDocumento=SP.IdSolicitudPedido
   WHERE O.IdDocumento=@IdSolicitudPedido
   AND IdTipoOperacion=2
   
   SELECT @HAY_DOCUMENTO_PR = APR.IdAjuntoPr 
   FROM dbo.DEA_AdjuntoPR  APR 
   WHERE IdSolicitudPedido=@IdSolicitudPedido
   AND APR.Activo=1 


   DECLARE @RESPONSE NVARCHAR(MAX)=''
 
    -- LA REQUISICION YA FUE APROBADA Y TIENE UN UN DOCUMENTO PR ENTONCES YA PASO POR EL ESTATUS DE MOSTRAR CARGA PR
   IF @ESTATUS_ACTUAL_SOLPED = 2 AND ISNULL(@HAY_DOCUMENTO_PR,0) > 0 
   BEGIN 
          SET @RESPONSE='MOSTRAR_DETALLE_PR'
         SELECT  @RESPONSE AS Estatus


         SELECT APR.IdAjuntoPr, APR.Comentario, APR.ID_PR AS NoPR, D.IdDocumento, D.NombreDocumento, u.Nombre AS CreadoPor, FORMAT(APR.CreadoEl,'dd/MM/yyyy hh:mm tt') AS CreadoEl
         FROM dbo.DEA_AdjuntoPR  APR 
         LEFT JOIN dbo.DEA_Documento_S3 D ON D.IdDocumentoTabla=APR.IdAjuntoPr 
         LEFT JOIN dbo.S_Usuario u ON u.IdUsuario= apr.CreadoPor
         WHERE IdSolicitudPedido=@IdSolicitudPedido
         AND APR.Activo=1 
         AND D.Activo=1
         AND D.IdTipoDocumento=1
   END 


   -- LA REQUISICION YA FUE APROBADA Y ESTA EN ESPERA DE CARGA DE DOCUMENTO
   IF @ESTATUS_ACTUAL_SOLPED = 11 AND ISNULL(@HAY_DOCUMENTO_PR,0) = 0
   BEGIN  
        SET @RESPONSE='MOSTRAR_CARGA_PR'
        SELECT  @RESPONSE AS Estatus
        
   END 


   -- SI LA SOLICITUD NO ESTA APROBADA O NO ESTA APRPBACIÓN SIN DOCUMENTO NO PERMITIR CARGAR DOCUMENTO/MOSTRAR MENSAJE 
   IF @ESTATUS_ACTUAL_SOLPED <> 11 AND @ESTATUS_ACTUAL_SOLPED <> 2 
   BEGIN  
            SET @RESPONSE='BLOQUEAR_CARGA_PR'
            SELECT  @RESPONSE AS Estatus
   END 


    IF @RESPONSE=''
   BEGIN  
        SELECT  'VALIDACIONES_NOCOMPLETADAS' AS Estatus,
            (SELECT NOMBRE FROM dbo.TA_Estatus WHERE IdEstatus= @ESTATUS_ACTUAL_SOLPED) AS EstatusRequisicion,
            @HAY_DOCUMENTO_PR AS NumeroAdjuntoPR,
            @IdSolicitudPedido AS NoSolPed
   END 


   
END

