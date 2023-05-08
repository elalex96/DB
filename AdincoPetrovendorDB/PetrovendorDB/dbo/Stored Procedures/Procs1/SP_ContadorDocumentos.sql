-- =============================================
-- Author:		Alexander G
-- Create date: 21/06/2017
-- Description:	Consulta la relación de Documento Proveedor mediante tipo de persona fiscal y cuenta los documentos cargados y faltantes
-- UPDATE DANIEL AC CAMBIO REFERENCIA A S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_ContadorDocumentos]

@IdTipoRegimen int,
@IdProveedor int
--@IdUsuario int

AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @ContadorTotalDocumentos int 
	declare @Incremento int 
	DECLARE @IdDocumentoTemp int


create table #TbTempDocumentos
(
IdRow int, 
IdDocumento int,
IdTipoDocumento int,
NombreTipoDocumento varchar(50),
TipoValidacionDocumento varchar(50) null
)

--drop table #TbTempDocumentos
INSERT INTO #TbTempDocumentos  
 SELECT  
 ROW_NUMBER() OVER(ORDER BY TPersona.[IdTipoDocumento]  ASC) AS Row#,
 0,
 TPersona.[IdTipoDocumento],
 TPersona.[NombreTipoDocumento],
 'Sin Documento'
 FROM [dbo].[S_TipoDocumento] AS TPersona
 INNER JOIN [dbo].[S_TipoDocumentoTipoPersona] AS TDocumentoPersona ON TDocumentoPersona.[IdTipoDocumento] = TPersona.[IdTipoDocumento]
 WHERE TDocumentoPersona.[IdTipoRegimen] = @IdTipoRegimen
 ORDER BY TPersona.[IdTipoDocumento]



 SET @ContadorTotalDocumentos = (SELECT COUNT(IdRow) FROM #TbTempDocumentos )

 SET @Incremento = 1

 WHILE @Incremento <= @ContadorTotalDocumentos
 BEGIN 


 set @IdDocumentoTemp = (SELECT IdTipoDocumento
						FROM #TbTempDocumentos
						WHERE IdRow = @Incremento)


DECLARE @ContadorDocumentosExistentes INT 

SET @ContadorDocumentosExistentes =(
 SELECT COUNT([IdDocumento]) AS ContadorDocumentosExistentes
 FROM [dbo].[S_Documento_S3]
 WHERE [IdTipoDocumento] = @IdDocumentoTemp
 ---AND IdUsuario = @IdUsuario
 AND IdProveedor = @IdProveedor AND Activo = 1)

 --- Validar 
 IF @ContadorDocumentosExistentes  > 0 
	 BEGIN 

		-- Existe Documennto 
		--- Actualizar Estatatus

		DECLARE @ESTATUS NVARCHAR(50) = ((
				 SELECT TVD.[TipoValidacion] AS ContadorDocumentosExistentes
				 FROM [dbo].[S_Documento_S3] AS D
				 INNER JOIN [dbo].[S_TipoValidacionDoc] AS TVD ON  TVD.[IdTipoValidacionDoc]= D.[IdTipoValidacionDocumento]
				 WHERE [IdTipoDocumento] = @IdDocumentoTemp
				 AND IdProveedor = @IdProveedor AND Activo = 1))
		
		DECLARE @IDDOCUMENTO INT =
				 (SELECT (SELECT D.[IdDocumento] AS  IdDocumento
				 FROM [dbo].[S_Documento_S3] AS D
				 WHERE [IdTipoDocumento] =@IdDocumentoTemp
				 AND IdProveedor = @IdProveedor AND Activo = 1) AS VALOR)


		--- ACTUALIZAR TABLA TEMPORAL 

		UPDATE #TbTempDocumentos
		SET  TipoValidacionDocumento = @ESTATUS,
		IdDocumento = ISNULL(@IDDOCUMENTO,0)
		WHERE IdRow = @Incremento

	 END 

		SET @Incremento = @Incremento + 1

	 END 


SELECT 
	   COUNT(CASE TbTemp.TipoValidacionDocumento WHEN 'En Aprobación' THEN 1 ELSE NULL END) AS DocPendientes,
	   COUNT(CASE TbTemp.TipoValidacionDocumento WHEN 'Sin Documento' THEN 1 ELSE NULL END) AS DocRestantes
       FROM #TbTempDocumentos AS TbTemp
END