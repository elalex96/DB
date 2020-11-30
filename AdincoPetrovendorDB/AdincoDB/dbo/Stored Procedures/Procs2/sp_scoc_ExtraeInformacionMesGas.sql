/****** Object:  StoredProcedure [dbo].[sp_scoc_ExtraeInformacionMesGas]    Script Date: 07/02/2019 02:12:27 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180905
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_scoc_ExtraeInformacionMesGas]
    @IdContrato INT,
    @IdUsuario INT,
    @mes DATE
AS
BEGIN

    SET NOCOUNT ON;



    SELECT 
c.NumeroContrato AS Contrato,
g.FechaReporte 	as	FechaReporteG,
g.FechaEntrega	as FechaEntregaG,
g.Dia	as DiaG,
u.Abreviatura AS UnidadMedida,
g.M3_20Grados	as M3_20Grados,
g.MMPC_NoAprov_20Grados	as MMPC_NoAprov_20Grados,
g.MMPC20BN AS MMPC20BN,
g.H2S	as H2S,
--g.GravEspec	as GravEspec,
g.CO2	as CO2,
g.N2	as N2,
g.C1	as C1,
g.C2	as C2,
g.C3	as C3,
g.IC4	as IC4,
g.NC4	as NC4,
g.IC5	as IC5,
g.NC5	as NC5,
g.C6	as C6,
g.c7 AS C7,
g.c8 AS C9,
g.c9 AS C8,
g.c10 AS C10,
g.PM	as PM,
g.PoderCalBTU	as PoderCalBTU,
g.DensidadRelativa	as DensidadRelativa,
g.FechaCromatografia AS FechaCromatografia,
CombustibleMTC,
CombustibleEC,
CombustibleCAB,
p.NombreCampo AS Campo,
Temperatura
    FROM SCOC_ReporteDiarioGas g
        JOIN CO_Contrato c
               on g.IdContrato = c.IdContrato
		JOIN dbo.CO_UnidadMedida U
		ON g.IdUnidadMedida=u.IdUnidadMedida
		JOIN dbo.SCOC_Campo p ON p.CampoID = g.CampoID
    WHERE IdContratista =
    (
        SELECT IdContratista FROM dbo.CO_Contrato WHERE IdContrato = @IdContrato
    )
          AND g.mesReporte = @mes
    ORDER BY g.IdContrato,g.FechaReporte;
END;
