CREATE TABLE [dbo].[QuitarLineasPCM_BAAC] (
    [id]                    INT            NULL,
    [id_actividad]          VARCHAR (100)  NULL,
    [actividad]             VARCHAR (100)  NULL,
    [id_subactividad]       VARCHAR (100)  NULL,
    [subactividad]          VARCHAR (250)  NULL,
    [id_tarea]              VARCHAR (50)   NULL,
    [tarea]                 VARCHAR (350)  NULL,
    [subtarea]              VARCHAR (2000) NULL,
    [pozo]                  VARCHAR (250)  NULL,
    [MontoOriginal]         FLOAT (53)     NULL,
    [MontoNvo]              FLOAT (53)     NULL,
    [idactividad]           INT            NULL,
    [idsubactividad]        INT            NULL,
    [idtarea]               INT            NULL,
    [idservicio]            INT            NULL,
    [idinstalacion]         INT            NULL,
    [IdLineaPresupuestoMes] INT            NULL
);

