CREATE TABLE [dbo].[SIPAC_RML_CNH_23_M] (
    [ID del contratista asignado por el SIPAC (RF_00)]                                                                                 NVARCHAR (255) NULL,
    [ID registro fiduciario del contrato (RI_00)]                                                                                      NVARCHAR (255) NULL,
    [ID del contrato asignado por CNH (RF01_01)]                                                                                       NVARCHAR (255) NULL,
    [Mes de reporte (RMLCH23_00)]                                                                                                      INT            NULL,
    [Año de reporte (RMLCH23_01)]                                                                                                      INT            NULL,
    [Volumen de producción del componente metano de gas natural no asociado registrado en el punto de medición (RMLCH23_02)]           FLOAT (53)     NULL,
    [Volumen de producción del componente etano de gas natural no asociado registrado en el punto de medición (RMLCH23_03)]            FLOAT (53)     NULL,
    [Volumen de producción del componente propano de gas natural no asociado registrado en el punto de medición (RMLCH23_04)]          FLOAT (53)     NULL,
    [Volumen de producción del componente butano de gas natural no asociado registrado en el punto de medición (RMLCH23_05)]           FLOAT (53)     NULL,
    [Volumen del componente metano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_06)]  FLOAT (53)     NULL,
    [Volumen del componente etano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_07)]   FLOAT (53)     NULL,
    [Volumen del componente propano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_08)] FLOAT (53)     NULL,
    [Volumen del componente butano de gas natural no asociado producido destinado al autoconsumo destrucción controlada (RMLCH23_09)]  FLOAT (53)     NULL,
    [Volumen de producción de condensados registrado en el punto de medición (RMLCH23_10)]                                             FLOAT (53)     NULL,
    [Volumen de condensados producidos destinados al autoconsumo (RMLCH23_11)]                                                         FLOAT (53)     NULL,
    [IdUsuario]                                                                                                                        INT            NULL,
    [IdContrato]                                                                                                                       INT            NULL
);

