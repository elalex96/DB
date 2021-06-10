CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionProveedorDocumentos]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, 
	@IdAceptacionPedido INT, 
	@Accion NVARCHAR(MAX), 
	@IdDocumento INT,
	@nombre			varchar(100)
AS
	BEGIN
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 06-01-2020
-- Description:	 Se modifico consulta de documentos, se le agrego left join a la ultima consulta
-- =============================================
-- BAAC 20210607	Se modifica para que regrese una cubeta, de acuerdo a donde se encuentra el archivo 
--					Si no se guarda que cubeta es, por default se manda la de petrovendor
-- =============================================
    SET NOCOUNT ON ;
    IF @Accion = 'TABLA'
        BEGIN
            SELECT      AD.[IdDocumento], AD.[NombreDocumento], AD.[Comentario]
            FROM        [dbo].[MM_AceptacionDocumento] AS AD
            INNER JOIN  [dbo].[MM_AceptacionPedido] AS AP
                ON AP.[IdAceptacionPedido] = AD.[IdAceptacionDocumento]
            WHERE
                        AP.[IdAceptacionPedido] = @IdAceptacionPedido
                        AND AP.[IdProveedor] = @IdProveedor
                        AND AD.[IdDocumento] IS NOT NULL
                        AND AD.Activo = 1
        END
    IF @Accion = 'DESCARGA'
        BEGIN

			/*CONSULTA EL DOCUMENTO EN LA TABLA DE DOCUMENTOS DE PETROVENDOR*/
            SELECT      AD.[IdDocumento], AD.[NombreDocumento], '' AS Documento, D.[Carpeta], D.[Extension] ,
                        D.Identificador, d.Bucket AS Bucket, D.Mime
			into		#tmp
            FROM        [dbo].[MM_AceptacionDocumento]	AS AD --[MM_AceptacionDocumento] where IdAceptacionDocumento = 907
            INNER JOIN  [dbo].[MM_AceptacionPedido]		AS AP
            ON			AP.[IdAceptacionPedido] = AD.[IdAceptacionDocumento]
            INNER JOIN  [dbo].[S_Documento_S3] AS D
            ON			D.[IdDocumento] = AD.[IdDocumento]
            WHERE
                        AP.[IdAceptacionPedido] = @IdAceptacionPedido
                        AND AP.[IdProveedor] = @IdProveedor
                        AND  AD.[IdDocumento] = @IdDocumento
                        AND AD.Activo = 1

				/*CONSULTA EL DOCUMENTO EN LA TABLA DE DOCUMENTOS DE PETROVENDOR -- CASO PARA OT´S */
			select		*
			into		#tmpAdinco
			from		Adinco..AWS_Documentos 
			where		NombreArchivo COLLATE Modern_Spanish_CI_AS 
			in			(
							select	NombreDocumento COLLATE Modern_Spanish_CI_AS 
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
			on			t2.NombreArchivo	=	t1.NombreDocumento	COLLATE Modern_Spanish_CI_AS
			where		((t1.NombreDocumento=	@nombre) or @nombre = '')
			AND t1.IdDocumento=@IdDocumento

        END
END
