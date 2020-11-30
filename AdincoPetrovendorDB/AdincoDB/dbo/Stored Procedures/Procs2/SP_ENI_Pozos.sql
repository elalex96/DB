-- =============================================
-- Author:		Manuel Cruz
-- Create date: 14-05-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENI_Pozos] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT C.NumeroContrato, 
                I.NombreInstalacion, 
                I.NombreInstalacionAlterno,
                CASE
                    WHEN EP.Descripcion = 'PERFORACIÓN - TERMINACIÓN'
                    THEN 'PERFORADO Y TERMINADO'
                    ELSE ep.Descripcion
                END AS EstadoPozo,
                CASE
                    WHEN I.IdInstalacion = 12566
                    THEN '2020-02-05'
                    ELSE NULL
                END AS FechaConfirmacionDescubrimiento, 
                I.IdInstalacion
         --,A.NombreActividad,A.IdActividad
         FROM dbo.CO_Instalacion I
              JOIN dbo.CO_ActividadCIEP A ON I.IdActividad = A.IdActividad
              JOIN dbo.CO_EstadoPozos EP ON EP.idEstatus = I.IdEstatus
              JOIN dbo.CO_AreaContractual AC ON I.IdAreaContractual = AC.IdAreaContractual
              JOIN dbo.CO_Contrato C ON AC.IdAreaContractual = C.IdAreaContractual
         WHERE C.IdContrato = @IdContrato --10049
               AND A.IdActividad = 5;
     END;