-- =============================================
-- Author:		Manuel Cruz
-- Create date: 14-05-2020
-- Description:	
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 01/06/2021
-- Description:	adecuaciones para grid js
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENI_Pozos] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT,
@Page INT,
@Buscar NVARCHAR(MAX)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

		DECLARE @AllRecords INT;
		DECLARE @RecordsByPage INT = 10;

		SET @AllRecords = (SELECT COUNT(1)
						 FROM dbo.CO_Instalacion I
							  JOIN dbo.CO_ActividadCIEP A ON I.IdActividad = A.IdActividad
							  JOIN dbo.CO_EstadoPozos EP ON EP.idEstatus = I.IdEstatus
							  JOIN dbo.CO_AreaContractual AC ON I.IdAreaContractual = AC.IdAreaContractual
							  JOIN dbo.CO_Contrato C ON AC.IdAreaContractual = C.IdAreaContractual
							  LEFT JOIN dbo.PR_Pozo AS PZ ON I.WelIID = PZ.Id
						 WHERE C.IdContrato = @IdContrato --10049
							   AND A.IdActividad = 5
							   AND (C.NumeroContrato LIKE '%' + @Buscar + '%'
									OR I.NombreInstalacion LIKE '%' + @Buscar + '%'
									OR I.NombreInstalacionAlterno LIKE '%' + @Buscar + '%'));

         SELECT *,
			  @AllRecords AS Records,
			  @RecordsByPage AS RecordsByPage
		FROM
		(
         SELECT ROW_NUMBER() OVER(PARTITION BY I.IdInstalacion ORDER BY I.IdInstalacion DESC) AS R,
				C.NumeroContrato, 
                I.NombreInstalacion, 
                I.NombreInstalacionAlterno,
                CASE
                    WHEN EP.Descripcion = 'PERFORACIÓN - TERMINACIÓN'
                    THEN 'PERFORADO Y TERMINADO'
                    ELSE ep.Descripcion
                END AS EstadoPozo,
                --PZ.FechaConfirmacionDescubrimiento AS FechaConfirmacionDescubrimiento, 
                I.IdInstalacion,
				I.WelIID,
				ISNULL(EP.Color,'#FFFFFF') AS Color,
				PZ.FechaConfirmacionDescubrimiento,
				PZ.ConfirmacionDescubrimiento,
				(ROW_NUMBER() OVER(ORDER BY I.IdInstalacion DESC) - 1) / @RecordsByPage AS _Page
         FROM dbo.CO_Instalacion I
              JOIN dbo.CO_ActividadCIEP A ON I.IdActividad = A.IdActividad
              JOIN dbo.CO_EstadoPozos EP ON EP.idEstatus = I.IdEstatus
              JOIN dbo.CO_AreaContractual AC ON I.IdAreaContractual = AC.IdAreaContractual
              JOIN dbo.CO_Contrato C ON AC.IdAreaContractual = C.IdAreaContractual
			  LEFT JOIN dbo.PR_Pozo AS PZ ON I.WelIID = PZ.Id
         WHERE C.IdContrato = @IdContrato --10049
               AND A.IdActividad = 5
			   AND (C.NumeroContrato LIKE '%' + @Buscar + '%'
					OR I.NombreInstalacion LIKE '%' + @Buscar + '%'
					OR I.NombreInstalacionAlterno LIKE '%' + @Buscar + '%')) AS R
		 WHERE R.R = 1 AND R._PAGE = (@Page - 1)
		 ORDER BY R.IdInstalacion DESC;

     END;
