CREATE PROCEDURE SP_PC_SIPAC_ConsideracionesAdministrativas 
	   @Contrato      INT,
	   @Mes           DATE
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 05-06-17
-- Description:	
-- =============================================
-- 20240628	RO	Se modifica para que se filtre la información de la tabla PR_VolumenMensualProduccionPetroleo por el Activo = 1
SET NOCOUNT ON

    SELECT  
	   CC.IDSIPAC	AS  RF_00,
	   C.IDRegFiducidiario AS RI_00,
	   C.NumeroContrato	   AS RF01_01,
	   MONTH(ISNULL(VMPP.MesReporte,VMPGNA.MesReporte))	AS RMPCT35_00,
	   YEAR(ISNULL(VMPP.MesReporte,VMPGNA.MesReporte))	AS RMPCT35_01,
	   CASE WHEN ISNULL(CONVERT(INT,VMPP.Bit_CasoFortuito),0) = 1 OR ISNULL(CONVERT(INT,VMPGNA.Bit_CasoFortuito),0) = 1
				THEN	   1
		  ELSE	0
	   END		AS RMPCT35_02,
	   ISNULL(VMPP.CantDiasCasoFortuito,0) + ISNULL(VMPGNA.CantDiasCasoFortuito,0)   AS RMPCT35_03,
	   ISNULL(VMPP.OtrosIngresosUsoCompartidoInfraestructura,0) + ISNULL(VMPGNA.OtrosIngresosUsoCompartidoInfraestructura,0)   AS RMPCT35_04
    FROM
    	  CO_Contrato	C	 (NOLOCK)
    JOIN
	   CO_Contratista  CC  (NOLOCK)
	   ON  C.IdContratista	   =	  CC.IdContratista
    LEFT JOIN
	   PR_VolumenMensualProduccionPetroleo VMPP	  (NOLOCK)
	   ON  C.IdContrato	   =	  VMPP.IdContrato
	   AND ISNULL(VMPP.Activo,0) = 1
    LEFT JOIN
	   PR_VolumenMensualProduccionGasNoAsoc VMPGNA	  (NOLOCK)
	   ON  C.IdContrato	   =	  VMPGNA.IdContrato
    WHERE
	   C.IdContrato    =   @Contrato
	   	AND ISNULL(VMPP.Activo,0) = 1
		AND
	   (VMPP.MesReporte	   =	  @Mes	OR  VMPGNA.MesReporte   = @Mes)

END
