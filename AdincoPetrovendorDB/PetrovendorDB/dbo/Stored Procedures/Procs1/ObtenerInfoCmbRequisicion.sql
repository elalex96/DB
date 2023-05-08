CREATE PROCEDURE ObtenerInfoCmbRequisicion
@IdProveedor INT,
@TipoCmb INT,
@IdContrato INT
AS
BEGIN
    --combo material
    IF (@TipoCmb = 1)
    BEGIN
        SELECT m.IdMaterial,
               CONCAT(
               ' Descripción: ',
               m.DescripcionCorta,
               ' Marca: ',
               CASE
                   WHEN ISNULL(LEN(m.Marca), 0) > 0 THEN
                       m.Marca
                   ELSE
                       ' S/M'
               END,
               ' Modelo: ',
               CASE
                   WHEN ISNULL(LEN(m.Modelo), 0) > 0 THEN
                       m.Modelo
                   ELSE
                       ' S/M'
               END,
               ' No. Parte: ',
               CASE
                   WHEN ISNULL(LEN(m.NumeroParte), 0) > 0 THEN
                       m.NumeroParte
                   ELSE
                       ' S/NP'
               END) AS Material
        FROM dbo.MM_Material m
        WHERE m.IdProveedor = @IdProveedor
              AND m.Activo = 1
    END
    -- combo domicilio
    IF (@TipoCmb = 2)
    BEGIN
        SELECT d.IdDomicilio,
               CONCAT(
               d.Calle,
               ' ',
               d.NoExterior,
               ' ',
               d.NoInterior,
               ' ',
               d.Colonia,
               ' ',
               d.Municipio,
               ' ',
               d.Estado,
               ' ',
               d.CodigoPostal,
               ' (',
               CAST(t.TipoDomicilio AS NVARCHAR(MAX)),
               ')') AS Domicilio
        FROM dbo.DG_Domicilio d
            INNER JOIN dbo.DG_TipoDomicilio t
                ON t.IdTipoDomicilio = d.IdTipoDomicilio
        WHERE d.IdProveedor = @IdProveedor
    END
    IF (@TipoCmb = 3)
    BEGIN
        SELECT m.IdUnidad,
               u.Unidad
        FROM dbo.PV_MM_MaterialUnidad u
            INNER JOIN dbo.MM_Material m
                ON m.IdUnidad = u.IdUnidad
        WHERE m.IdProveedor = @IdProveedor
              AND u.IsActivo = 1
              AND ISNULL(u.IsEliminado, 0) = 0
        GROUP BY m.IdUnidad,
                 u.Unidad
        ORDER BY u.Unidad
    END
    IF (@TipoCmb = 4)
    BEGIN
        SELECT IdCentroCosto,
               CentroCosto
        FROM dbo.CC_CentroCosto
        WHERE IdProveedor = @IdProveedor
              AND IsActivo = 1
    END
    IF (@TipoCmb = 5)
    BEGIN
        SELECT i.IdInstalacion,
               i.NombreInstalacion
        FROM Adinco.dbo.CO_Instalacion i
            INNER JOIN Adinco.dbo.CO_Contrato c
                ON c.IdAreaContractual = i.IdAreaContractual
        WHERE c.IdContrato = @IdContrato
    END
    IF (@TipoCmb = 6)
    BEGIN
        SELECT lpm.IdLineaPresupuestoMes,
               CONCAT(
               'Mes Programado: ',
               RIGHT('00' + LTRIM(MONTH(lpm.AC_PRESUP_MES)), 2),
               ' ',
               dbo.Fn_RetornarMesEspanol(MONTH(lpm.AC_PRESUP_MES)),
               ' ',
               YEAR(lpm.AC_PRESUP_MES),
               ' | Actividad: ',
               CASE
                   WHEN CO.IdTipoContrato = 1 THEN
                       TS.NombreTipoServicio
                   ELSE
                       APCNH.DescripcionActividadPetrolera
               END COLLATE Modern_Spanish_CI_AS,               -- Actividad
               ' | Sub-Actividad: ',
               CASE
                   WHEN CO.IdTipoContrato = 1 THEN
                       ACIEP.NombreActividad
                   ELSE
                       SAP.SubactividadPetrolera
               END COLLATE Modern_Spanish_CI_AS,               -- SubActividad
               ' | Tarea: ',
               TP.TareaPetrolera COLLATE Modern_Spanish_CI_AS, -- Tarea
               ' | Clave Tarea: ',
               TP.id_Tarea COLLATE Modern_Spanish_CI_AS,       -- Clave Tarea
               ' | Sub-Tarea: ',
               S.NombreServicio COLLATE Modern_Spanish_CI_AS) -- Sub Tarea  
               AS subTarea
        FROM Adinco.dbo.CO_LineaPresupuestoMes lpm
            LEFT JOIN Adinco.dbo.CO_Registro R
                ON lpm.IdLineaPresupuestoMes = R.IdPrograma
            LEFT JOIN Adinco.dbo.FI_Factura F
                ON R.IdFactura = F.IdFactura
            LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD
                ON F.IdMoneda = TCD.IdMoneda
                   AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                   AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                   AND DAY(TCD.Fecha) = DAY(F.Fecha)
            LEFT JOIN Adinco.dbo.CO_Presupuesto P
                ON P.IdPresupuesto = lpm.IdPresupuesto
            LEFT JOIN Adinco.dbo.CO_AnioContractual AC
                ON AC.IdAnioContractual = P.IdAnioContractual
            LEFT JOIN Adinco.dbo.CO_Contrato CO
                ON CO.IdContrato = AC.IdContrato
            LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH APCNH
                ON lpm.IdActividadPetrolera = APCNH.IdActividadPetrolera
            LEFT JOIN Adinco.dbo.CO_SubactividadPetrolera SAP
                ON lpm.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
            LEFT JOIN Adinco.dbo.CO_TareaPetrolera TP
                ON lpm.IdTareaPetrolera = TP.IdTareaPetrolera
            LEFT JOIN Adinco.dbo.CO_ActividadCIEP AS ACIEP
                ON lpm.IdActividad = ACIEP.IdActividad
            LEFT JOIN Adinco.dbo.CO_TipoServicio TS
                ON lpm.IdTipoServicio = TS.ID_TIPOSER
            LEFT JOIN Adinco.dbo.CO_Servicio S
                ON lpm.IdServicio = S.IdServicio
            LEFT JOIN Adinco.dbo.CO_Instalacion I
                ON lpm.IdInstalacion = I.IdInstalacion
        WHERE AC.IdContrato = @IdContrato
              AND S.Activo = 1
    END
END