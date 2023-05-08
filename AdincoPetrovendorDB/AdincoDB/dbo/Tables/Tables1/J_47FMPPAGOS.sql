CREATE TABLE [dbo].[J_47FMPPAGOS] (
    [ID del contratista asignado por el SIPAC (RF_00)]                 NVARCHAR (255) NULL,
    [ID registro fiduciario del contrato (RI_00)]                      NVARCHAR (255) NULL,
    [ID del contrato asignado por la CNH (RI_01)]                      NVARCHAR (255) NULL,
    [Mes de reporte (RM47_01)]                                         FLOAT (53)     NULL,
    [Año de reporte (RM47_02)]                                         FLOAT (53)     NULL,
    [Regalía Base: Pagos recibidos al 17 natural (RM47_03)]            FLOAT (53)     NULL,
    [Regalía Base: Pagos recibidos en el periodo de ajustes por difer] FLOAT (53)     NULL,
    [Regalía Base: Pagos recibidos posterior al periodo de ajuste de ] FLOAT (53)     NULL,
    [Regalía Adicional: Pagos recibidos al 17 natural (RM47_06)]       FLOAT (53)     NULL,
    [Regalía Adicional: Pagos recibidos en el periodo de ajustes por ] FLOAT (53)     NULL,
    [Regalía Adicional: Pagos recibidos posterior al periodo de ajust] FLOAT (53)     NULL,
    [Cuota Exploratoria: Pagos recibidos al 17 natural (RM47_09)]      FLOAT (53)     NULL,
    [Cuota Exploratoria: Pagos recibidos en el periodo de ajustes por] FLOAT (53)     NULL,
    [Cuota Exploratoria: Pagos recibidos posterior al periodo de ajus] FLOAT (53)     NULL,
    [Pagos recibidos por pena convencional (RM47_12)]                  FLOAT (53)     NULL,
    [Pagos recibidos por pena convencional (RM47_13)]                  FLOAT (53)     NULL,
    [Otros pagos al Estado recibidos en USD (RM47_14)]                 FLOAT (53)     NULL,
    [Otros pagos al Estado recibidos en MXN (RM47_15)]                 FLOAT (53)     NULL,
    [Estado (activo)]                                                  NVARCHAR (255) NULL,
    [Fecha registro (fechaRegistro)]                                   NVARCHAR (255) NULL
);

