/****** Object:  StoredProcedure [dbo].[sp_scoc_ExtraeInformacionMesPetroleo]    Script Date: 07/02/2019 02:12:44 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180905
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_scoc_ExtraeInformacionMesPetroleo]
    @IdContrato INT,
    @IdUsuario INT,
    @mes DATE
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @Balance INT;

    SELECT @Balance = Balance
    FROM dbo.SCOC_Contrato
    WHERE IdContrato = @IdContrato;

    IF (@Balance = 0)
    BEGIN
        SELECT c.NumeroContrato AS Contrato,
               p.FechaReporte AS FechaReporteP,
               p.FechaEntrega AS FechaEntregaP,
               U.Abreviatura AS UnidadMedida,
               p.Dia AS DiaP,
               p.M3_20Grados AS Volumen,
               Temperatura,
               p.GradosAPI AS GradosAPI,
               p.AguaSedimento AS AguaSedimento,
               --p.ViscosidadSSU	 as ViscosidadSSU,
               p.Sal AS Sal,
               p.Azufre AS Azufre,
               --p.PresionEntrega	 as PresionEntrega,
               --p.PoderCalorifico	 as PoderCalorifico,
               p.PesoEspec AS PesoEspec,
               pu.NombreCampo AS Campo,
               ObservacionesContratista,
               ObservacionesComercializador
        FROM SCOC_ReporteDiarioPetroleo p
            JOIN CO_Contrato c
                ON p.IdContrato = c.IdContrato
            JOIN dbo.CO_UnidadMedida U
                ON p.IdUnidadMedida = U.idUnidadMedida
            JOIN dbo.SCOC_Campo pu
                ON pu.CampoID = p.CampoID
            JOIN SCOC_ComentariosReportes co
                ON co.IdContrato = p.IdContrato
                   AND co.MesReporte = p.MesReporte
                   AND ProductoNominacionID =
                   (
                       SELECT ProductoNominacionID
                       FROM CO_ClasificacionProductoNominacion
                       WHERE NombreCNH = 'Petroleo'
                   )
        WHERE IdContratista =
        (
            SELECT IdContratista FROM dbo.CO_Contrato WHERE IdContrato = @IdContrato
        )
              AND p.MesReporte = @mes
        ORDER BY p.IdContrato,
                 p.FechaReporte;
    END;
    ELSE
    BEGIN
        SELECT c.NumeroContrato AS Contrato,
               p.FechaReporte AS FechaReporteP,
               p.FechaEntrega AS FechaEntregaP,
               U.Abreviatura AS UnidadMedida,
               p.Dia AS DiaP,
               p.M3_20Grados AS Volumen,
               p.Volumen15Grados AS Volumen15Grados,
               p.GradosAPI AS GradosAPI,
               p.AguaSedimento AS AguaSedimento,
               p.Sal AS Sal,
               p.Azufre AS Azufre,
               p.PesoEspec AS PesoEspec,
               pu.NombreCampo AS Campo,
               ObservacionesContratista,
               ObservacionesComercializador
        FROM SCOC_ReporteDiarioPetroleo p
            JOIN CO_Contrato c
                ON p.IdContrato = c.IdContrato
            JOIN dbo.CO_UnidadMedida U
                ON p.IdUnidadMedida = U.idUnidadMedida
            JOIN dbo.SCOC_Campo pu
                ON pu.CampoID = p.CampoID
            JOIN SCOC_ComentariosReportes co
                ON co.IdContrato = p.IdContrato
                   AND co.MesReporte = p.MesReporte
                   AND ProductoNominacionID =
                   (
                       SELECT ProductoNominacionID
                       FROM CO_ClasificacionProductoNominacion
                       WHERE NombreCNH = 'Petroleo'
                   )
        WHERE IdContratista =
        (
            SELECT IdContratista FROM dbo.CO_Contrato WHERE IdContrato = @IdContrato
        )
              AND p.MesReporte = @mes
        ORDER BY p.IdContrato,
                 p.FechaReporte;
    END;
END;
