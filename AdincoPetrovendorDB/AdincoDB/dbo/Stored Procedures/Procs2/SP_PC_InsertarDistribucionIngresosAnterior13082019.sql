create PROCEDURE [dbo].[SP_PC_InsertarDistribucionIngresosAnterior13082019]
	@IdUsuario  INT,
	@IdContrato INT,
	@MesReporte NVARCHAR(50)
AS
BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 27-10-2017
-- Description:	
-- =============================================
SET NOCOUNT ON
SET LANGUAGE Spanish
-- =============================================
CREATE TABLE #Contratos
(
	IdContrato	INT
)

DECLARE  @Fecha	DATE

SELECT @Fecha = CONVERT(DATE,SUBSTRING(@MesReporte,7,4)+SUBSTRING(@MesReporte,4,2)+SUBSTRING(@MesReporte,1,2),112)
 
DELETE PC_DistribucionIngresos 
WHERE MesReporte = @MesReporte

INSERT INTO #Contratos
(
    IdContrato
)
SELECT
	IdContrato
FROM
	PC_ContratoCampo
GROUP BY
	IdContrato

INSERT INTO [dbo].[PC_DistribucionIngresos]
(
	[IdContrato],
    [MesReporte],
    [IdSector],
    [IdMaterialPC],
    [IdPtoExpedicionRecepcion],
    [IdRegion],
    [IdActivo],
    [IdCampo],
    [ParticipacionVolumetrica],
    [FactorDistribucionVolumetrica],
    [DistribucionVolumetrica],
    [IdUnidadMedida],
    [GPVMaximoPorCampo],
    [GPVMaximoPorMaterial],
    [GPVPonderadoPorCampo],
    [PrecioEquilibrio],
    [PrecioReferencia],
    [FactorDistribucionIngresos],
    [DistribucionIngresos],
    [DistribucionIngresosMonedaLocal],
    [IdMonedaLocal],
    [DistrubucionIngresosUSD],
    [IdMonedaLocal2],
    [IdOrganismo],
    [CreadoPor],
    [CreadoEn]
)
    SELECT
		CC.IdContrato,
        CONVERT(VARCHAR(11), REPLACE(CONCAT('01.', I.Mes), '.', '/'), 120) AS Mes,
        S.IdSector,
        M.IdMaterialPC,
        PER.IdPtoExpedicionRecepcion,
        R.IdRegion,
        A.IdActivo,
        C.IdCampo,
        I.[Participación Volumétrica],
        I.[Factor de Distribución Volumétrica],
        I.[Distribución Volumétrica],
        UM.IdUnidadMedida,
        I.[GPV Ponderado por Campo],
        I.[GPV máximo por Material],
        I.[GPV Ponderado por Campo],
        I.[Precio de Equilibrio],
        I.[Precio de Referencia],
        I.[Factor de Distribución de Ingresos],
        I.[Distribución de Ingresos],
        I.[Distribución de Ingresos en Moneda Local],
        CASE
            WHEN I.[Moneda local] = 'MXP'
            THEN 1
            WHEN I.[Moneda local] = 'USD'
            THEN 2
        END AS [Moneda local],
        I.[Distribución de Ingresos en USD],
        CASE
            WHEN I.[Mon#local 2] = 'MXP'
            THEN 1
            WHEN I.[Mon#local 2] = 'USD'
            THEN 2
        END AS [Moneda local 2],
        O.IdOrganismo,
        @IdUsuario AS CreadoPor,
        GETDATE() AS CreadoEn
    FROM PC_Ingresos I
    JOIN PC_Sector S 
		ON I.Sector = S.CvSector
    JOIN PC_Material M 
		ON I.[Texto breve de material] = M.TextoBreve
    JOIN PC_PtoExpedicionRecepcion PER 
		ON I.Denominación = PER.Denominacion
    JOIN CO_Region R 
		ON I.[Región] = R.[No]
    JOIN PC_Activo A 
		ON I.[Cve#Activo] = A.CveActivo
    JOIN PC_Campo C 
		--ON I.[Cve#Cmpo#] = C.CvCampo
		ON	CASE WHEN ISNUMERIC(I.[Cve#Cmpo#]) = 1 THEN LTRIM(CONVERT(INT, I.[Cve#Cmpo#])) ELSE I.[Cve#Cmpo#] END	=	CASE WHEN ISNUMERIC(C.CvCampo) = 1 THEN LTRIM(CONVERT(INT, C.CvCampo)) ELSE C.CvCampo END
    JOIN PC_ContratoCampo CC 
		ON C.IdCampo = CC.IdCampo
 	JOIN #Contratos	CO
		ON	CC.IdContrato	=	CO.IdContrato
    JOIN PC_UnidadMedidaVenta UM 
		ON I.[Un#medida venta] = UM.UnidadMedida
    JOIN PC_Organismo O 
		ON I.[Organismo secundario] = O.OrganismoSecundario
	WHERE
	YEAR (CONVERT(DATE,SUBSTRING(CONCAT('01.', I.Mes),7,4)+SUBSTRING(CONCAT('01.', I.Mes),4,2)+SUBSTRING(CONCAT('01.', I.Mes),1,2),112))	=	YEAR(@Fecha)
	AND MONTH (CONVERT(DATE,SUBSTRING(CONCAT('01.', I.Mes),7,4)+SUBSTRING(CONCAT('01.', I.Mes),4,2)+SUBSTRING(CONCAT('01.', I.Mes),1,2),112))	=	MONTH(@Fecha)
END