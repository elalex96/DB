CREATE TABLE [dbo].[lineascambioPCM] (
    [ID]                    INT           NULL,
    [id_Actividad_ANT]      VARCHAR (15)  NULL,
    [id_Sub_actividad_ANT]  VARCHAR (15)  NULL,
    [id_Tarea_ANT]          VARCHAR (15)  NULL,
    [Servicio_Subtarea_ANT] VARCHAR (500) NULL,
    [Instalacion_ANT]       VARCHAR (250) NULL,
    [id_Actividad_NVO]      VARCHAR (15)  NULL,
    [id_Sub_actividad_NVO]  VARCHAR (15)  NULL,
    [id_Tarea_NVO]          VARCHAR (15)  NULL,
    [Servicio_Subtarea_NVO] VARCHAR (500) NULL,
    [Instalacion_NVO]       VARCHAR (250) NULL,
    [IdActividad_ANT]       INT           NULL,
    [IdSubactividad_ANT]    INT           NULL,
    [IdTarea_ANT]           INT           NULL,
    [IdServicio_ANT]        INT           NULL,
    [IdInstalacion_ANT]     INT           NULL,
    [IdActividad_NVO]       INT           NULL,
    [IdSubactividad_NVO]    INT           NULL,
    [IdTarea_NVO]           INT           NULL,
    [IdServicio_NVO]        INT           NULL,
    [IdInstalacion_NVO]     INT           NULL
);

