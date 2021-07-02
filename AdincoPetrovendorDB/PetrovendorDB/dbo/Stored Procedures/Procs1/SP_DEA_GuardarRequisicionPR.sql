USE [Petrovendor]
GO


IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DEA_GuardarRequisicionPR'
)
    DROP PROCEDURE SP_DEA_GuardarRequisicionPR;

/****** Object:  StoredProcedure [dbo].[SP_DEA_GuardarRequisicionPR]    Script Date: 02/07/2021 10:40:20 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	Agregar referencia a  documentos 
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	Se agrega eliminacion de documentos si ya existia una PR antes de ser aprobada
-- =============================================
CREATE  PROCEDURE[dbo].[SP_DEA_GuardarRequisicionPR] 
	-- Add the parameters for the stored procedure here
		 
	@IdProveedor INT,
	@IdUsuario INT,
	@NoRequisicionPR NVARCHAR(MAX),
	@NoSolicitudPedido INT,
	@Comentario NVARCHAR(MAX)

AS
	
BEGIN				
	
	DECLARE @ExisteRegistro INT 
	DECLARE @IdDocumento INT
	DECLARE @NoPR NVARCHAR(MAX) 
	DECLARE @IdDocumentoRespaldo INT
	DECLARE @ESTATUS_ACTUAL_SOLPED INT 

	/*VALIDAR ESTATUS ACTUAL DE LA REQUISICION*/
   SELECT @ESTATUS_ACTUAL_SOLPED= IdEstatusOperacion 
   FROM MM_SolicitudPedido SP
   JOIN TA_Operacion  O ON O.IdDocumento=SP.IdSolicitudPedido
   WHERE O.IdDocumento=@NoSolicitudPedido
   AND IdTipoOperacion=2


	SELECT @ExisteRegistro=IdSolicitudPedido FROM dbo.DEA_AdjuntoPR WHERE IdSolicitudPedido=@NoSolicitudPedido AND IdProveedor=@IdProveedor

	IF ISNULL(@ExisteRegistro,0)=0
	BEGIN 
     INSERT INTO dbo.DEA_AdjuntoPR
     (
         IdSolicitudPedido,        
         IdProveedor,
         Comentario,
         CreadoPor,
         CreadoEl,         
         Activo,       
         ID_PR
     )
     VALUES
     (   @NoSolicitudPedido,         -- IdSolicitudPedido - int         
         @IdProveedor,         -- IdProveedor - int
         @Comentario,       -- Comentario - nvarchar(max)
         @IdUsuario,         -- CreadoPor - int
         GETDATE(), -- CreadoEl - datetime        
         1,      -- Activo - bit         
         @NoRequisicionPR        -- ID_PR - nvarchar(30)
       )

	  SELECT @@IDENTITY AS IdAdjuntoPR

	END 
	ELSE 
	BEGIN 
		
		IF ISNULL(@ESTATUS_ACTUAL_SOLPED,0)=11
		BEGIN 
		/*SI YA EXISTE UN ARCHIVO ELIMINARLO PARA CARGAR EL NUEVO ARCHIVO, 
		ESTO PARA PASAR LA REQUISICION DEL ESTATUS APROBADA INTERNANMENTE A APROBADO 
		FORZAZAMENTE YA CON EL ARCHIVO QUE ESTA CARGANDO EN ESTE MOMENTO EL USUARIO*/

		/*OBTENER LA REFERENCIA DEL DOCUMENTO PR ACTUAL*/
			SELECT @IdDocumento=D.IdDocumento ,
			@NoPR=PR.ID_PR
			FROM DEA_AdjuntoPR PR  
			JOIN DEA_Documento_S3 D 
			ON D.IdDocumentoTabla=PR.IdAjuntoPr 
			AND D.IdTipoDocumento=1 --> AdjuntoPR (SELECT * FROM dbo.DEA_TipoDocumento)  
			WHERE PR.IdSolicitudPedido = @NoSolicitudPedido
			AND PR.IdProveedor=@IdProveedor

			 --PASAR DOCUMENTO A TABLA DE HISTORIAL DE DOCUMENTOS   Y ELIMINAR REFERENCIA AL DOCUMENTO PR
			IF ISNULL(@IdDocumento,0)>0
			BEGIN
				--SI HAY DOCUMENTO PASAR AL HISTORIAL DE DOCUMENTOS 
				 INSERT INTO [dbo].[DEA_DocumentoHistorial_S3]  
				 (  
				  [IdDocumento],  
				  [IdTipoDocumento],    
				  [IdProveedor],  
				  [Activo],   
				  [CreadoPor],  
				  [CreadoEl],  
				  [Descripcion],  
				  [Carpeta],  
				  [Identificador],  
				  [Mime],  
				  [Extension],  
				  [NombreDocumento],  
				  [SizeDocumento],    
				  [IdDocumentoTabla]  
				 )   
  
				 SELECT   
				 IdDocumento,  
				 IdTipoDocumento,  
				 IdProveedor,  
				 Activo,  
				 CreadoPor,  
				 CreadoEl,  
				 CONCAT(Descripcion,' #Eliminado por CARGA DE NUEVA PR Requisición ',CAST(@NoSolicitudPedido as nvarchar(max)) ,'-PR:',+ISNULL(@NoPR,'')),  
				 Carpeta,  
				 Identificador,  
				 Mime,  
				 Extension,  
				 NombreDocumento,  
				 SizeDocumento,  
				 IdDocumentoTabla  --> ESTE VA SER LA REFERENCIA A LA TABLA DEA_AdjuntoPR QUE SE VA ELIMINAR
				 FROM dbo.DEA_Documento_S3   
				 WHERE IdDocumento=@IdDocumento 
				 
				 SELECT @IdDocumentoRespaldo = @@IDENTITY  
				 DELETE DEA_Documento_S3 WHERE IdDocumento=@IdDocumento	
			  END 

			 /*ELIMINAR REFERENCIA AL ADJUNTO PR*/
			 DELETE DEA_AdjuntoPR
			 WHERE IdSolicitudPedido=@NoSolicitudPedido
			 AND IdProveedor=@IdProveedor

			 /*INSERTAR EN BITACORA*/
			BEGIN 

			INSERT INTO [dbo].[BitacoraErrores]
				   ([HResult]
				   ,[Mensaje]
				   ,[StackTrace]
				   ,[IdUsuario]
				   ,[IdProveedor]
				   ,[FechaRegistro])
			 VALUES
				   (0
				   ,'ELIMINACION DOCUMENTO PR FORZADA'
				   ,CONCAT('#Eliminado por CARGA DE NUEVA DE NUEVA PR Requisición No.',CAST(@NoSolicitudPedido as nvarchar(max)),
				   ' RESPANDO DOCUMENTO EN DEA_DocumentoHistorial_S3 WHERE IdDocumentoHistorial_S3=',CAST(ISNULL(@IdDocumentoRespaldo,0)as nvarchar(max)), 
				   ' La requisicion estaba con estatus en Aprobada sin Documento --> PERO YA TENIA UN DOCUMENTO RELACIONADO')
				   ,@IdUsuario
				   ,@IdProveedor
				   , GETDATE())

			END 
			 /*INSERTAR LA NUEVA*/
				  INSERT INTO dbo.DEA_AdjuntoPR
			 (
				 IdSolicitudPedido,        
				 IdProveedor,
				 Comentario,
				 CreadoPor,
				 CreadoEl,         
				 Activo,       
				 ID_PR
			 )
			 VALUES
			 (   @NoSolicitudPedido,         -- IdSolicitudPedido - int         
				 @IdProveedor,         -- IdProveedor - int
				 @Comentario,       -- Comentario - nvarchar(max)
				 @IdUsuario,         -- CreadoPor - int
				 GETDATE(), -- CreadoEl - datetime        
				 1,      -- Activo - bit         
				 @NoRequisicionPR        -- ID_PR - nvarchar(30)
			   )

		  SELECT @@IDENTITY AS IdAdjuntoPR

		  END
		ELSE 
		BEGIN 

			SELECT 'YA_EXISTE_PR'
		END 
	END 

END


