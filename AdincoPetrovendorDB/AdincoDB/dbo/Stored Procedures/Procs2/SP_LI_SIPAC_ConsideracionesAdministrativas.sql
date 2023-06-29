CREATE PROCEDURE [dbo].[SP_LI_SIPAC_ConsideracionesAdministrativas] 
	@Contrato INT, 
	@Mes      DATE,
	@IdUsuario	INT = 1
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 19-06-17
-- Description:	
-- 20190319	BAAC	Se agrega el usuario
-- =============================================
    SET NOCOUNT ON;

    SELECT CC.IDSIPAC AS RF_00, 
        C.IdRegFiducidiario AS RI_00, 
        C.NumeroContrato AS RF01_01,
        --CASE
        --WHEN LTRIM(REPLICATE('0', 2-LEN(MONTH(VMPP.MesReporte))))+LTRIM(MONTH(VMPP.MesReporte)) IS NULL
        --THEN LTRIM(REPLICATE('0', 2-LEN(MONTH(VMPGNA.MesReporte))))+LTRIM(MONTH(VMPGNA.MesReporte))
        --ELSE LTRIM(REPLICATE('0', 2-LEN(MONTH(VMPP.MesReporte))))+LTRIM(MONTH(VMPP.MesReporte)) 
        --END 
        CASE
            WHEN MONTH(VMPP.MesReporte) IS NULL
            THEN MONTH(VMPGNA.MesReporte)
            ELSE MONTH(VMPP.MesReporte)
        END AS RMLCT28_00, 
        YEAR(ISNULL(VMPP.MesReporte, VMPGNA.MesReporte)) AS RMLCT28_01,
        CASE
            WHEN ISNULL(CONVERT(INT, VMPP.Bit_CasoFortuito), 0) = 1
                    OR ISNULL(CONVERT(INT, VMPGNA.Bit_CasoFortuito), 0) = 1
            THEN 1
            ELSE 0
        END AS RMLCT28_02, 
        ISNULL(VMPP.CantDiasCasoFortuito, 0) + ISNULL(VMPGNA.CantDiasCasoFortuito, 0) AS RMLCT28_03, 
        ISNULL(CONVERT(DECIMAL(14, 2), VMPP.OtrosIngresosUsoCompartidoInfraestructura), 0) + ISNULL(CONVERT(DECIMAL(14, 2), VMPGNA.OtrosIngresosUsoCompartidoInfraestructura), 0) AS RMLCT28_04
    FROM CO_Contrato C(NOLOCK)
        LEFT JOIN CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
        LEFT JOIN PR_VolumenMensualProduccionPetroleo VMPP(NOLOCK) ON C.IdContrato = VMPP.IdContrato
		AND ISNULL(VMPP.Activo,0) = 1
        LEFT JOIN PR_VolumenMensualProduccionGasNoAsoc VMPGNA(NOLOCK) ON C.IdContrato = VMPGNA.IdContrato
                                                                        AND VMPP.MesReporte = @Mes
    WHERE C.IdContrato = @Contrato
        AND VMPP.MesReporte = @Mes
		AND ISNULL(VMPP.Activo,0) = 1
        OR VMPGNA.MesReporte = @Mes;
    --EXEC SP_LI_SIPAC_ConsideracionesAdministrativas 10011,'2017-03-01'
END;