
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Abel Rivera
-- Create date: 21/06/2017
-- Description:	Consulta la relación de Documento Proveedor mediante tipo de persona fiscal
-- =============================================
CREATE PROCEDURE [dbo].[SP_PorcenDocSistemaGestion]

--@IdTipoRegimen int,
@IdProveedor int
--@IdUsuario int

AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Variable int 
	declare @Incremento int 
	DECLARE @Contador int


create table #TbTempDocCargados
(
IdRow int,
IdTipoDocumento int,
NombreTipoDocumento varchar(50),
Activo bit,
Estatus nvarchar(50)
)

--drop table #TbTempDocumentos
INSERT INTO #TbTempDocCargados  
 SELECT  
 ROW_NUMBER() OVER(ORDER BY DSG.[IdDocSistemaGestion]  ASC) AS Row#,
DSG.[IdDocSistemaGestion],
DSG.[DocSistemaGestion],
 0,
 'Sin Documento'
 FROM [dbo].[PV_DocSistemGestion] AS DSG
 --WHERE DSG.[IdProveedor] = @IdProveedor
 ORDER BY DSG.[IdDocSistemaGestion]



 SET @Variable = (SELECT COUNT(IdDocSistemaGestion) FROM PV_DocSistemGestion)

 SET @Contador = 1

 WHILE @Contador <= @Variable
 BEGIN 
 DECLARE @IdTD INT = (
				 SELECT IdTipoDocumento 
				 FROM [dbo].[#TbTempDocCargados] 
				 WHERE [IdRow] = @Contador)

DECLARE @CONDICION INT = (SELECT COUNT(IdTipoDocSG) FROM PV_SistemaGestion WHERE IdTipoDocSG = @IdTD AND Activo = 1 AND IdProveedor = @IdProveedor)


IF @CONDICION = 1
BEGIN
 DECLARE @IdTDR INT = (
				 SELECT SG.IdTipoDocSG 
				 FROM [dbo].[PV_DocSistemGestion] AS DSG
				 INNER JOIN PV_SistemaGestion  AS SG ON SG.IdTipoDocSG = DSG.IdDocSistemaGestion
				 WHERE SG.IdProveedor = @IdProveedor AND SG.Activo = 1 AND SG.IdTipoDocSG = @IdTD)


		--- ACTUALIZAR TABLA TEMPORAL 
		IF @IdTD = @IdTDR
		BEGIN
			UPDATE #TbTempDocCargados
			SET  
			Activo = 1,
			Estatus = 'Documento Cargado'
			WHERE IdTipoDocumento = @IdTD
		END
		--	ELSE
		--BEGIN
		--	SELECT * FROM #TbTempDocCargados
		--END
		END
	IF @CONDICION > 1
	BEGIN
		UPDATE #TbTempDocCargados
			SET  
			Activo = 1,
			Estatus = 'Documento Cargado'
			WHERE IdTipoDocumento = @IdTD
	END
       SET @Contador = @Contador + 1
	END 

	DECLARE @PORC_POR_DOC INT 
	DECLARE @PORC_SUBIDO INT = 0
	DECLARE @CANT_DOC_CARGADOS INT = (SELECT COUNT (IdRow) FROM #TbTempDocCargados WHERE Activo = 1)
	DECLARE @CANT_DOC_TOTAL INT = (SELECT COUNT (IdRow) FROM #TbTempDocCargados)

    SET @PORC_POR_DOC = (100/@CANT_DOC_TOTAL)
	SET @PORC_SUBIDO = (@CANT_DOC_CARGADOS * @PORC_POR_DOC)

	IF (@PORC_SUBIDO >= 98)
	SET @PORC_SUBIDO = 100

	DECLARE @PorcentajeRestante INT=(100 - @PORC_SUBIDO)

	SELECT @PORC_SUBIDO AS PORCENTAJECARGADO, @PorcentajeRestante AS PORCENTAJERESTANTE



	--DECLARE @PorcentajeSubido INT=0
	--DECLARE @OTRA INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDocSG = 5)
	--IF @OTRA >= 1
	--BEGIN
	--UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 1,
	--		Estatus = 'Documento Cargado'
	--		WHERE IdTipoDocumento = 5
	--		SET @PorcentajeSubido = @PorcentajeSubido +14
		
	--END
	--ELSE
	--BEGIN
	--	UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 0,
	--		Estatus = 'Sin Documento'
	--		WHERE IdTipoDocumento = 5
	--END

	--DECLARE @PCN INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDocSG = 4)
	--IF @PCN >= 1
	--BEGIN
	--UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 1,
	--		Estatus = 'Documento Cargado'
	--		WHERE IdTipoDocumento = 4
	--		SET @PorcentajeSubido = @PorcentajeSubido +14
		
	--END
	--ELSE
	--BEGIN
	--	UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 0,
	--		Estatus = 'Sin Documento'
	--		WHERE IdTipoDocumento = 4
	--END

	--DECLARE @CESR INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDocSG = 3)
	--IF @CESR >= 1
	--BEGIN
	--UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 1,
	--		Estatus = 'Documento Cargado'
	--		WHERE IdTipoDocumento = 3
	--		SET @PorcentajeSubido = @PorcentajeSubido +14
	--END
	--ELSE
	--BEGIN
	--	UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 0,
	--		Estatus = 'Sin Documento'
	--		WHERE IdTipoDocumento = 3
	--END

	--DECLARE @ISO180 INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDocSG = 2)
	--IF @ISO180 >= 1
	--BEGIN
	--UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 1,
	--		Estatus = 'Documento Cargado'
	--		WHERE IdTipoDocumento = 2
	--		SET @PorcentajeSubido = @PorcentajeSubido +14
	--END
	--ELSE
	--BEGIN
	--	UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 0,
	--		Estatus = 'Sin Documento'
	--		WHERE IdTipoDocumento = 2
	--END

	--DECLARE @ISO140 INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDocSG = 1)
	
	--IF @ISO140 >= 1
	--BEGIN
	--UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 1,
	--		Estatus = 'Documento Cargado'
	--		WHERE IdTipoDocumento = 1
	--		SET @PorcentajeSubido = @PorcentajeSubido +14
	--END
	--ELSE
	--BEGIN
	--	UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 0,
	--		Estatus = 'Sin Documento'
	--		WHERE IdTipoDocumento = 1
	--END

	--DECLARE @ISO900 INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDocSG = 6)
	
	--IF @ISO900 >= 1
	--BEGIN
	--UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 1,
	--		Estatus = 'Documento Cargado'
	--		WHERE IdTipoDocumento = 6
	--		SET @PorcentajeSubido = @PorcentajeSubido +14
	--END
	--ELSE
	--BEGIN
	--	UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 0,
	--		Estatus = 'Sin Documento'
	--		WHERE IdTipoDocumento = 6
	--END

	--DECLARE @CIL INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDocSG = 7)
	
	--IF @CIL >= 1
	--BEGIN
	--UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 1,
	--		Estatus = 'Documento Cargado'
	--		WHERE IdTipoDocumento = 7
	--		SET @PorcentajeSubido = @PorcentajeSubido +14
	--END
	--ELSE
	--BEGIN
	--	UPDATE #TbTempDocCargados
	--		SET  
	--		Activo = 0,
	--		Estatus = 'Sin Documento'
	--		WHERE IdTipoDocumento = 7
	--END


END
