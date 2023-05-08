
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Abel Rivera
-- Create date: 21/06/2017
-- Description:	Consulta la relación de Documento Proveedor mediante tipo de persona fiscal
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_DocSistemaGestion]

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

	SELECT * FROM #TbTempDocCargados
	
END
