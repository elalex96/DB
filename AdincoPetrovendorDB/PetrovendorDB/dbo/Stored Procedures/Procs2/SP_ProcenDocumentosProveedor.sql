---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Alexander G
-- Create date: 21/06/2017
-- Description:	Consulta la relación de Documento Proveedor mediante tipo de persona fiscal y cuenta los documentos cargados y faltantes
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Modified date: 10/01/2018
-- Description:	Ocurrio un error al cargar dos documentos 
--				(marco error al estar subiendo un documento y se subieron dos archivos con el mismo proveedor para evitar error se subquery 
--				se utiliza el top 1 ordeado desc para que tome el ultimo archivo subido)
--update Daniel AC cambio de referencia de S_Documento a S_Documento_S3
-- =============================================
-- =============================================
-- Author:			Ramón Portales
-- Modified date:	28/03/2022
-- Description:		Se validó un posible división entre cero (select @PORC_POR_DOCUMENTO = (100/@CANT_DOC_TOTAL))
-- =============================================
CREATE PROCEDURE [dbo].[SP_ProcenDocumentosProveedor] 

@IdTipoRegimen int,
@IdProveedor int

AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @ContadorTotalDocumentos int 
	declare @Incremento int 
	DECLARE @IdDocumentoTemp int
	DECLARE @Porcentaje int


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


 SET @ContadorTotalDocumentos = (SELECT COUNT(IdRow) FROM #TbTempDocumentos)

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
				 SELECT TOP 1 TVD.[TipoValidacion] AS ContadorDocumentosExistentes
				 FROM [dbo].[S_Documento_S3] AS D
				 INNER JOIN [dbo].[S_TipoValidacionDoc] AS TVD ON  TVD.[IdTipoValidacionDoc]= D.[IdTipoValidacionDocumento]
				 WHERE [IdTipoDocumento] = @IdDocumentoTemp
				 AND IdProveedor = @IdProveedor AND Activo = 1 ORDER BY D.IdDocumento DESC))
		
		DECLARE @IDDOCUMENTO INT =
				 (SELECT (SELECT TOP 1 D.[IdDocumento] AS  IdDocumento
				 FROM [dbo].[S_Documento_S3] AS D
				 WHERE [IdTipoDocumento] =@IdDocumentoTemp
				 AND IdProveedor = @IdProveedor AND Activo = 1 ORDER BY IdDocumento DESC) AS VALOR)


		--- ACTUALIZAR TABLA TEMPORAL 

		UPDATE #TbTempDocumentos
		SET  TipoValidacionDocumento = @ESTATUS,
		IdDocumento = ISNULL(@IDDOCUMENTO,0)
		WHERE IdRow = @Incremento


	 END 

		SET @Incremento = @Incremento + 1

	 END 

	 DECLARE @CANT_DOC_CARGADOS INT = (SELECT COUNT (IdRow) FROM #TbTempDocumentos WHERE TipoValidacionDocumento = 'Documento Cargado')
	 DECLARE @CANT_DOC_TOTAL INT = (SELECT COUNT (IdRow) FROM #TbTempDocumentos)
	 DECLARE @PORC_DOC_SUBIDO INT 
	 DECLARE @PORC_DOC_RESTANTE INT
	 DECLARE @PORC_POR_DOCUMENTO INT 

	 --if(isnull(@CANT_DOC_TOTAL,0)=0)
	 --begin
		--select @PORC_POR_DOCUMENTO = 0
	 --end	
	 --else
	 --begin
			select @PORC_POR_DOCUMENTO = (100/@CANT_DOC_TOTAL)
	 --end

	 SET @PORC_DOC_SUBIDO = (@CANT_DOC_CARGADOS * @PORC_POR_DOCUMENTO)

	 IF (@PORC_DOC_SUBIDO >= 98)
	    SET @PORC_DOC_SUBIDO = 100

     SET @PORC_DOC_RESTANTE = (100 - @PORC_DOC_SUBIDO)

	 SELECT @PORC_DOC_SUBIDO AS PorcentajeSubido,@PORC_DOC_RESTANTE AS PorcentajeRestante

END

