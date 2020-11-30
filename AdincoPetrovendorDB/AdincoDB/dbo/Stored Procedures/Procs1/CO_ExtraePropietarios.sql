-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180814
-- Description:	Extrae propietarios
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraePropietarios]--10061,3
    @IdUsuario INT = 0,
    @IdContrato INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdRelacionado INT;

    IF OBJECT_ID('tempdb..#Contratos') IS NOT NULL
        DROP TABLE #Contratos;
    CREATE TABLE #Contratos
    (
        IdContrato INT
    );

    SELECT @IdRelacionado = REL.IdRelacionado
    FROM dbo.CO_Contrato C
        JOIN CO_ContratistaRelacionado REL
            ON C.IdContratista = REL.IdContratista
    WHERE C.IdContrato = @IdContrato;

    -- SI NO HAY CONTRATISTAS RELACIONADOS, SE INSERTAN TODOS LOS CONTRATOS DEL MISMO SUBCONTRATISTA    
    IF ISNULL(@IdRelacionado, 0) = 0
    BEGIN
        INSERT INTO #Contratos
        (
            IdContrato
        )
        SELECT C2.IdContrato
        FROM dbo.CO_Contrato C
            JOIN dbo.CO_Contrato C2
                ON C.IdContratista = C2.IdContratista
        WHERE C.IdContrato = @IdContrato;
    END;
    ELSE
    BEGIN
        INSERT INTO #Contratos
        (
            IdContrato
        )
        SELECT C.IdContrato
        FROM dbo.CO_Contrato C
            JOIN CO_ContratistaRelacionado REL
                ON C.IdContratista = REL.IdContratista
        WHERE REL.IdRelacionado = @IdRelacionado;

    END;


    SELECT IdPropietario,
           NombrePropietario,
           AC.NombreAreaContractual,
           AC.IdAreaContractual,
           PR.KM2 AS KM2,
           PR.FechaIniPago AS FI,
		   RFC,
		   PR.Correo AS correo,
		   PR.Telefono AS telefono,
		   PR.Direccion AS direccion,
           Bit_Activo,
		   MontoRenta
    FROM dbo.CO_PropietariosAreaContractual PR
        JOIN dbo.CO_AreaContractual AC
            ON PR.IdAreaContractual	=	AC.IdAreaContractual 
        JOIN dbo.CO_Contrato
            ON  AC.IdAreaContractual	=	CO_Contrato.IdAreaContractual
    WHERE IdContrato IN (
                           SELECT IdContrato FROM #Contratos
                        )
		GROUP BY IdPropietario,
           NombrePropietario,
           AC.NombreAreaContractual,
           AC.IdAreaContractual,
           PR.KM2 ,
           PR.FechaIniPago ,
		   RFC,
		   PR.Correo ,
		   PR.Telefono ,
		   PR.Direccion ,
           Bit_Activo,
		   MontoRenta


END;


