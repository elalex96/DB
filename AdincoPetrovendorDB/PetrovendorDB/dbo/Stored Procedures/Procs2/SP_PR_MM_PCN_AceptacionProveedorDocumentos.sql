USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_PR_MM_PCN_AceptacionProveedorDocumentos
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionProveedorDocumentos]
	-- Add the parameters for the stored procedure here
	@IdProveedor		INT, 
	@IdAceptacionPedido INT, 
	@Accion				NVARCHAR(MAX), 
	@IdDocumento		INT,
	@nombre				varchar(100)
AS
	BEGIN
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 06-01-2020
-- Description:	 Se modifico consulta de documentos, se le agrego left join a la ultima consulta
-- =============================================
-- BAAC 20210607	Se modifica para que regrese una cubeta, de acuerdo a donde se encuentra el archivo 
--					Si no se guarda que cubeta es, por default se manda la de petrovendor
-- =============================================
-- Author:		Ramón Portales
-- Create date: 09-12-2021
-- Description:	Se modificó la ultima consulta, se movio el filtro por UUID al join y se quitó del where
-- =============================================
-- Author:		Luis David
-- Create date: 13/06/2022
-- Description:	Se retorna la tabla de documentos de Field Ticket y Proforma
-- =============================================
-- Author:		Luis David
-- Create date: 04/07/2022
-- Description:	Cuando sea null se obtendrán las 4 ultimas del nombre (para la extensión)
-- =============================================
DECLARE @IdDocumentoFieldTicket INT = (SELECT IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = 'FIELD TICKET'),
		@IdDocumentoProforma INT = (SELECT IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = 'PROFORMA');
DECLARE @IdPedido INT = (SELECT TOP 1 AP.IdPedido
						FROM dbo.MM_AceptacionPedido AP
						LEFT JOIN dbo.MM_Pedido P 
						ON AP.IdPedido = P.IdPedido
						WHERE  P.IdProveedorCompras = @IdProveedor
							  AND AP.IdAceptacionPedido = @IdAceptacionPedido);
DECLARE @IdSolicitudAceptacionPedido INT = (SELECT IdSolicitudAceptacionPedido 
											FROM MM_SolicitudAceptacionPedido 
											WHERE IdPedido = @IdPedido AND IdAceptacionPedido = @IdAceptacionPedido)
    SET NOCOUNT ON ;
    IF @Accion = 'TABLA'
        BEGIN
            SELECT   AD.[IdDocumento], AD.[NombreDocumento], AD.[Comentario], US.Nombre, D.CreadoEl
            FROM  [dbo].[MM_AceptacionDocumento] AS AD (NOLOCK)
            JOIN  [dbo].[MM_AceptacionPedido] AS AP (NOLOCK)
                ON AD.[IdAceptacionDocumento] = AP.[IdAceptacionPedido] 
			INNER JOIN  [dbo].[S_Documento_S3] AS D (NOLOCK)
				ON	AD.[IdDocumento] = D.[IdDocumento] 
			LEFT JOIN S_Usuario AS US (NOLOCK)
				ON US.IdUsuario = D.IdUsuario 
            WHERE
                        AP.[IdAceptacionPedido] = @IdAceptacionPedido
                        AND AP.[IdProveedor] = @IdProveedor
                        AND AD.[IdDocumento] IS NOT NULL
                        AND AD.Activo = 1
			/*TABLA DE DOCUMENTO FIELD TICKET*/
			SELECT  D.IdDocumento, 
					D.NombreDocumento /*+ '  -  Cargado Por ' +  US.Nombre + ' el ' + CAST(D.CreadoEl AS nvarchar)*/ AS NombreDocumento, 
					'FIELDTICKET' AS Comentario,
					'' AS Nombre,
					D.CreadoEl
					--D.IdDocumentoTabla 
			 FROM  S_Documento_S3 D  
			 LEFT JOIN S_Usuario AS US ON D.IdUsuario = US.IdUsuario
			 WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
			 AND D.Activo=1 
			 AND D.IdTipoDocumento = @IdDocumentoFieldTicket
			 /*TABLA DE DOCUMENTO PROFORMA*/
			SELECT  D.IdDocumento, 
					D.NombreDocumento /*+ '  -  Cargado Por ' +  US.Nombre + ' el ' + CAST(D.CreadoEl AS nvarchar)*/ AS NombreDocumento, 
					'PROFORMA' AS Comentario,
					'' AS Nombre,
					D.CreadoEl
					--D.IdDocumentoTabla 
			 FROM  S_Documento_S3 D  
			 LEFT JOIN S_Usuario AS US ON D.IdUsuario = US.IdUsuario
			 WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
			 AND D.Activo=1 
			 AND D.IdTipoDocumento = @IdDocumentoProforma
        END
    IF @Accion = 'DESCARGA'
        BEGIN

			/*CONSULTA EL DOCUMENTO EN LA TABLA DE DOCUMENTOS DE PETROVENDOR*/
            SELECT      AD.[IdDocumento], AD.[NombreDocumento], '' AS Documento, D.[Carpeta], ISNULL(D.[Extension],RIGHT(AD.[NombreDocumento], 4)) AS 'Extension' ,
                        D.Identificador, d.Bucket AS Bucket, D.Mime
			into		#tmp
            FROM        [dbo].[MM_AceptacionDocumento]	AS AD (NOLOCK)
            JOIN  [dbo].[MM_AceptacionPedido]		AS AP (NOLOCK)
            ON			AD.[IdAceptacionDocumento] = AP.[IdAceptacionPedido] 
            JOIN  [dbo].[S_Documento_S3] AS D (NOLOCK)
            ON			 AD.[IdDocumento] = D.[IdDocumento]
            WHERE
                        AP.[IdAceptacionPedido] = @IdAceptacionPedido
                        AND AP.[IdProveedor]	= @IdProveedor
                        AND  AD.[IdDocumento]	= @IdDocumento
                        AND AD.Activo = 1

				/*CONSULTA EL DOCUMENTO EN LA TABLA DE DOCUMENTOS DE PETROVENDOR -- CASO PARA OT´S */
			select		*
			into		#tmpAdinco
			from		Adinco..AWS_Documentos  (NOLOCK)
			where		UUIDAmazon --COLLATE Modern_Spanish_CI_AS 
			in			(
							select	Identificador --COLLATE Modern_Spanish_CI_AS 
							from	#tmp) 

				
			/*RETORNA EL DOCUMENTO CORRECTO*/
			select		t1.IdDocumento,
						t1.NombreDocumento,
						t1.Documento,
						Carpeta				=	ISNULL(t1.Carpeta,t2.Folder),
						Extension			=	ISNULL(t1.Extension,substring(t2.Meta,13,15)),
						Identificador		=	ISNULL(t1.Identificador,t2.UUIDAmazon),
						Bucket				=	COALESCE(t1.Bucket,t2.Bucket, 'petrovendor-pr' COLLATE Modern_Spanish_CI_AS) ,--ISNULL(t1.Bucket,t2.Bucket),
						t1.Mime
			from		#tmp				t1
			left join	#tmpAdinco			t2
			on			t1.NombreDocumento	COLLATE Modern_Spanish_CI_AS = t2.NombreArchivo	
			and			t1.Identificador	=	t2.UUIDAmazon
			where		t1.IdDocumento		=	@IdDocumento

        END
END
