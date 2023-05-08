CREATE TABLE [dbo].[SIPAC_RML_CNH_22_M] (
    [ID del contratista asignado por el SIPAC (RF_00)]                                                                                 NVARCHAR (255) NULL,
    [ID registro fiduciario del contrato (RI_00)]                                                                                      NVARCHAR (255) NULL,
    [ID del contrato asignado por CNH (RF01_01)]                                                                                       NVARCHAR (255) NULL,
    [Mes de reporte (RMLCH22_00)]                                                                                                      INT            NULL,
    [Año de reporte (RMLCH22_01)]                                                                                                      INT            NULL,
    [Volumen de producción de petróleo registrado en el punto de medición (RMLCH22_02)]                                                FLOAT (53)     NULL,
    [Grados API del petróleo producido, promedio ponderado (RMLCH22_03)]                                                               FLOAT (53)     NULL,
    [Contenido de azufre del petróleo producido, promedio ponderado (RMLCH22_04)]                                                      FLOAT (53)     NULL,
    [Volumen de petróleo producido destinado al autoconsumo (RMLCH22_05)]                                                              FLOAT (53)     NULL,
    [Volumen de producción del componente metano de gas natural asociado registrado en el punto de medición (RMLCH22_06)]              FLOAT (53)     NULL,
    [Volumen de producción del componente etano de gas natural asociado registrado en el punto de medición (RMLCH22_07)]               FLOAT (53)     NULL,
    [Volumen de producción del componente propano de gas natural asociado registrado en el punto de medición (RMLCH22_08)]             FLOAT (53)     NULL,
    [Volumen de producción del componente butano de gas natural asociado registrado en el punto de medición (RMLCH22_09)]              FLOAT (53)     NULL,
    [Volumen del componente metano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_10)] FLOAT (53)     NULL,
    [Volumen del componente etano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_11)]  FLOAT (53)     NULL,
    [Volumen del componente propano de gas natural asociado producido destinado al autoconsumo destrucción controlada (RMLCH22_12)]    FLOAT (53)     NULL,
    [Volumen del componente butano de gas natural asociado producido destinado al autoconsumo y/o destrucción controlada (RMLCH22_13)] FLOAT (53)     NULL,
    [Volumen de producción de condensados registrado en el punto de medición (RMLCH22_14)]                                             FLOAT (53)     NULL,
    [Volumen de condensados producidos destinados al autoconsumo (RMLCH22_15)]                                                         FLOAT (53)     NULL,
    [IdUsuario]                                                                                                                        INT            NULL,
    [IdContrato]                                                                                                                       INT            NULL
);

