-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180905
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE sp_scoc_ExtraeInformacionMes
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
g.M3_20Grados	as M3_20Grados,
g.MMPC_NoAprov_20Grados	as MMPC_NoAprov_20Grados,
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
g.PM	as PM,
--g.LIC	as LIC,
g.PoderCalBTU	as PoderCalBTU,
--g.PoderCalorificoKCA	as PoderCalorificoKCA,
--g.TempFlujo	as TempFlujo,
--g.PresionFlujo	as PresionFlujo,
		
		
		
  p.FechaReporte	 as	  FechaReporteP,
p.FechaEntrega	 as FechaEntregaP,
p.Dia	 as DiaP,
--p.Bls	 as Bls,
p.GradosAPI	 as GradosAPI,
p.AguaSedimento	 as AguaSedimento,
--p.ViscosidadSSU	 as ViscosidadSSU,
p.Sal	 as Sal,
p.Azufre	 as Azufre,
--p.PresionEntrega	 as PresionEntrega,
--p.PoderCalorifico	 as PoderCalorifico,
p.PesoEspec	 as PesoEspec
    FROM SCOC_ReporteDiarioGas g
        JOIN SCOC_ReporteDiarioPetroleo p
            ON p.IdContrato = g.IdContrato
               AND p.fechaReporte = g.FechaReporte
        JOIN CO_Contrato c
            ON p.IdContrato = c.IdContrato
               AND g.IdContrato = c.IdContrato
    WHERE IdContratista =
    (
        SELECT IdContratista FROM dbo.CO_Contrato WHERE IdContrato = @IdContrato
    )
          AND g.mesReporte = @mes
    ORDER BY g.IdContrato,p.idContrato,g.FechaReporte,p.FechaReporte;
END;
